import pygame
import random
import math
from PIL import Image, ImageDraw, ImageFont

# ------------------------------
# Constants
# ------------------------------
SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
BACKGROUND_COLOR = (0, 0, 0)          # black
GOLD_COLOR = (255, 215, 0)            # pure gold
GOLD_DARK = (200, 150, 0)             # darker gold for gradient / edge
TURQUOISE_BRIGHT = (0, 255, 220)      # bright turquoise text
TEXT_FONT_SIZE_PT = 60
TEXT_SIDE_PADDING = 40

NUM_PIECES = 220                      # number of foil pieces
FALL_SPEED_BASE = 2.5                # base downward speed (pixels per frame)
FALL_SPEED_VARIATION = 1.0           # random addition/subtraction
ROTATION_SPEED_VARIATION = 0.1      # rad/frame variation (0 = none)
FLUTTER_AMPLITUDE = 2.0              # max horizontal shift (pixels)
FLUTTER_FREQ = 0.05                  # rad/frame base frequency

# 5x7 block glyphs for static fallback text rendering (avoids pygame.font dependency).
_GLYPHS_5x7 = {
    "A": ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
    "C": ["01110", "10001", "10000", "10000", "10000", "10001", "01110"],
    "G": ["01110", "10001", "10000", "10111", "10001", "10001", "01110"],
    "I": ["11111", "00100", "00100", "00100", "00100", "00100", "11111"],
    "L": ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
    "N": ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
    "O": ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
    "R": ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
    "S": ["01111", "10000", "10000", "01110", "00001", "00001", "11110"],
    "T": ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
    "U": ["10001", "10001", "10001", "10001", "10001", "10001", "01110"],
    "!": ["00100", "00100", "00100", "00100", "00100", "00000", "00100"],
    " ": ["00000", "00000", "00000", "00000", "00000", "00000", "00000"],
}


def render_block_text(text, color, scale=8, letter_spacing=2):
    text = text.upper()
    glyph_h = 7 * scale
    glyph_w = 5 * scale
    total_w = 0
    for ch in text:
        total_w += glyph_w + letter_spacing * scale
    if total_w > 0:
        total_w -= letter_spacing * scale
    surf = pygame.Surface((max(total_w, 1), glyph_h), pygame.SRCALPHA)
    x_cursor = 0
    for ch in text:
        rows = _GLYPHS_5x7.get(ch, _GLYPHS_5x7[" "])
        for row_i, row in enumerate(rows):
            for col_i, bit in enumerate(row):
                if bit == "1":
                    rect = pygame.Rect(x_cursor + col_i * scale, row_i * scale, scale, scale)
                    pygame.draw.rect(surf, color, rect)
        x_cursor += glyph_w + letter_spacing * scale
    return surf


def render_normal_text(text, color, font_size=TEXT_FONT_SIZE_PT, side_padding=TEXT_SIDE_PADDING):
    """Render centered text using an Arial-family TrueType font with side padding."""
    text = text.upper()
    font = None
    # Prefer Arial-family normal TrueType fonts.
    for family_path in (
        "Arial.ttf",
        "arial.ttf",
        "/Library/Fonts/Arial.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
        "/System/Library/Fonts/Supplemental/Arial Narrow.ttf",
        "LiberationSans-Regular.ttf",
        "DejaVuSans.ttf",
    ):
        try:
            font = ImageFont.truetype(family_path, font_size)
            break
        except Exception:
            continue
    if font is None:
        # Fallback if truetype font is unavailable.
        return render_block_text(text, color, scale=9, letter_spacing=1)
    # Measure text bounding box.
    probe = Image.new("RGBA", (1, 1), (0, 0, 0, 0))
    draw = ImageDraw.Draw(probe)
    x0, y0, x1, y1 = draw.textbbox((0, 0), text, font=font)
    width = max(1, x1 - x0)
    height = max(1, y1 - y0)
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.text((-x0, -y0), text, font=font, fill=(color[0], color[1], color[2], 255))
    glyph_surface = pygame.image.fromstring(img.tobytes(), img.size, "RGBA").convert_alpha()
    # Add equal horizontal space and center the glyphs inside it.
    padded_surface = pygame.Surface(
        (glyph_surface.get_width() + side_padding * 2, glyph_surface.get_height()),
        pygame.SRCALPHA,
    )
    glyph_rect = glyph_surface.get_rect(center=padded_surface.get_rect().center)
    padded_surface.blit(glyph_surface, glyph_rect.topleft)
    return padded_surface

# ------------------------------------------------------------
# Foil piece class – holds all properties and drawing logic
# ------------------------------------------------------------
class FoilPiece:
    def __init__(self):
        # Random size (thin rectangles look like foil strips)
        self.width = random.uniform(6, 18)
        self.height = random.uniform(4, 10)
        # Initial position (top part of screen)
        self.x = random.uniform(0, SCREEN_WIDTH - self.width)
        self.y = random.uniform(-self.height, SCREEN_HEIGHT // 2)
        # Rotation and angular velocity
        self.angle = random.uniform(0, 2 * math.pi)
        self.ang_vel = random.uniform(-ROTATION_SPEED_VARIATION, ROTATION_SPEED_VARIATION)
        # Fall speed (pixels per frame)
        self.fall_speed = FALL_SPEED_BASE + random.uniform(-FALL_SPEED_VARIATION, FALL_SPEED_VARIATION)
        # Flutter phase (offset in sine wave)
        self.flutter_phase = random.uniform(0, 2 * math.pi)
        # Pre‑create a surface for this rectangle (so we can rotate it)
        self.create_surface()

    def create_surface(self):
        """Create a rectangular surface with a golden gradient."""
        # Create a surface with per‑pixel alpha for transparency
        surf = pygame.Surface((int(self.width), int(self.height)), pygame.SRCALPHA)
        # Draw a simple gold rectangle (you can add a gradient later)
        # For a gradient effect, we draw a top‑to‑bottom gradient from bright gold to dark gold
        for y in range(int(self.height)):
            ratio = y / self.height
            color = (
                int(GOLD_COLOR[0] * (1 - ratio) + GOLD_DARK[0] * ratio),
                int(GOLD_COLOR[1] * (1 - ratio) + GOLD_DARK[1] * ratio),
                int(GOLD_COLOR[2] * (1 - ratio) + GOLD_DARK[2] * ratio),
                255
            )
            pygame.draw.line(surf, color, (0, y), (self.width, y))
        # Optional: add a thin gold edge (border)
        pygame.draw.rect(surf, GOLD_DARK, surf.get_rect(), 1)
        self.surface = surf

    def update(self, frame):
        """Update position, rotation, and fluttering."""
        # Update rotation angle
        self.angle += self.ang_vel

        # Fall downwards
        self.y += self.fall_speed

        # Horizontal flutter: sine wave based on frame number or y‑position
        # Using the frame gives a time‑based effect independent of y
        offset_x = FLUTTER_AMPLITUDE * math.sin(FLUTTER_FREQ * frame + self.flutter_phase)
        self.x += offset_x  # we add the offset each frame – this accumulates a wandering motion

        # Alternative: if you want the flutter to be independent of movement, you'd set
        # self.x = self.original_x + offset_x, but here we accumulate to keep it simple.

        # Wrap horizontally (so pieces don't go off screen sides)
        if self.x < -self.width:
            self.x = SCREEN_WIDTH
        elif self.x > SCREEN_WIDTH:
            self.x = -self.width

        # Reset if fallen below screen
        if self.y > SCREEN_HEIGHT:
            self.reset()

    def reset(self):
        """Bring piece back to the top with a new random horizontal position and a fresh look."""
        self.x = random.uniform(0, SCREEN_WIDTH - self.width)
        self.y = random.uniform(-self.height, 0)      # start just above screen
        self.ang_vel = random.uniform(-ROTATION_SPEED_VARIATION, ROTATION_SPEED_VARIATION)
        self.fall_speed = FALL_SPEED_BASE + random.uniform(-FALL_SPEED_VARIATION, FALL_SPEED_VARIATION)
        self.flutter_phase = random.uniform(0, 2 * math.pi)
        # Optionally change size for variety (or keep same)
        self.width = random.uniform(12, 28)
        self.height = random.uniform(4, 10)
        self.create_surface()   # recreate surface with new dimensions

    def draw(self, screen):
        """Draw the rotated rectangle onto the screen."""
        # Rotate the surface around its center
        rotated_surf = pygame.transform.rotate(self.surface, math.degrees(self.angle))
        # Get the new rect and position it so its center stays at the piece's center
        rect = rotated_surf.get_rect(center=(self.x + self.width/2, self.y + self.height/2))
        screen.blit(rotated_surf, rect.topleft)


# ------------------------------------------------------------
# Main program
# ------------------------------------------------------------
def main():
    pygame.init()
    screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
    pygame.display.set_caption("Gold Foil Fluttering")
    clock = pygame.time.Clock()
    title_surface = render_normal_text("CONGRATULATIONS!", TURQUOISE_BRIGHT, font_size=TEXT_FONT_SIZE_PT)
    title_rect = title_surface.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2))
    text_layer = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT), pygame.SRCALPHA)
    text_layer.blit(title_surface, title_rect)
    foil_layer = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT), pygame.SRCALPHA)

    # Create all foil pieces
    pieces = [FoilPiece() for _ in range(NUM_PIECES)]

    running = True
    frame = 0
    while running:
        # Handle events
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

        # Update all pieces
        for p in pieces:
            p.update(frame)

        # Draw everything
        screen.fill(BACKGROUND_COLOR)
        # Static text layer (behind foil layer).
        screen.blit(text_layer, (0, 0))
        # Draw foil on transparent layer above text.
        foil_layer.fill((0, 0, 0, 0))
        for p in pieces:
            p.draw(foil_layer)
        screen.blit(foil_layer, (0, 0))

        pygame.display.flip()
        clock.tick(60)   # 60 frames per second
        frame += 1

    pygame.quit()


if __name__ == "__main__":
    main()
