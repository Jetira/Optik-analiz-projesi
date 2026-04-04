"""Sabit degerler, esikler ve ayarlar."""

# Bubble detection (Faz 2'de kullanilacak)
BUBBLE_FILL_THRESHOLD = 0.5
BUBBLE_CIRCULARITY_MIN = 0.7

# QR detection
QR_MIN_DETECTED = 3

# Image processing
GAUSSIAN_BLUR_KERNEL = (5, 5)
ADAPTIVE_THRESH_BLOCK = 11
ADAPTIVE_THRESH_C = 2

# Exam limits
MAX_QUESTIONS = 100
MAX_GROUPS = 4

# Valid choices
VALID_CHOICES_4 = ["A", "B", "C", "D"]
VALID_CHOICES_5 = ["A", "B", "C", "D", "E"]

# Image settings (Flutter tarafinda da kullanilir)
IMAGE_RESIZE_WIDTH = 1600
IMAGE_JPEG_QUALITY = 80

# ---------------------------------------------------------------------------
# Template generation (A4 @ 300 DPI)
# ---------------------------------------------------------------------------
TEMPLATE_WIDTH = 2480       # px
TEMPLATE_HEIGHT = 3508      # px
TEMPLATE_DPI = 300

# QR code placement
QR_SIZE = 180               # QR image size in px (>= 150)
QR_MARGIN = 60              # distance from page edge to QR edge

# Title / group label
TITLE_Y = 120               # center Y for exam title
GROUP_LABEL_Y = 220         # center Y for "GRUP X" label

# Student info boxes
STUDENT_INFO_Y = 310        # top Y of student info area
STUDENT_INFO_HEIGHT = 180   # box height
STUDENT_INFO_MARGIN_X = 260 # left/right page margin for boxes
STUDENT_INFO_GAP = 60       # gap between the two boxes

# Bubble grid — these values are used by BOTH template generator and reader
BUBBLE_GRID_START_Y = 560   # center Y of first bubble row
BUBBLE_DIAMETER = 36        # circle diameter (~3 mm @ 300 DPI)
BUBBLE_SPACING_X = 60       # center-to-center horizontal between choices
ROW_HEIGHT = 52             # center-to-center vertical between question rows
QUESTION_LABEL_WIDTH = 100  # horizontal space reserved for question number
TWO_COLUMN_THRESHOLD = 30   # use 2 columns when soru_sayisi > this
COLUMN_GAP = 120            # horizontal gap between two columns

# Bubble reader — ROI crop margin (px inward from bubble edge)
BUBBLE_CROP_MARGIN = 4

# Font sizes (px)
FONT_SIZE_TITLE = 72
FONT_SIZE_GROUP = 100
FONT_SIZE_LABEL = 32
FONT_SIZE_QUESTION = 28
FONT_SIZE_CHOICE = 26

# ---------------------------------------------------------------------------
# Config validation — baslatma sirasinda hatalari yakala
# ---------------------------------------------------------------------------

def _validate_config() -> None:
    """Sabit degerlerin gecerli araliklarda oldugundan emin ol."""
    assert 0.0 < BUBBLE_FILL_THRESHOLD < 1.0, \
        f"BUBBLE_FILL_THRESHOLD 0-1 arasi olmali, mevcut: {BUBBLE_FILL_THRESHOLD}"
    assert 0.0 < BUBBLE_CIRCULARITY_MIN < 1.0, \
        f"BUBBLE_CIRCULARITY_MIN 0-1 arasi olmali, mevcut: {BUBBLE_CIRCULARITY_MIN}"
    assert 1 <= QR_MIN_DETECTED <= 4, \
        f"QR_MIN_DETECTED 1-4 arasi olmali, mevcut: {QR_MIN_DETECTED}"
    assert 1 <= MAX_QUESTIONS <= 200, \
        f"MAX_QUESTIONS 1-200 arasi olmali, mevcut: {MAX_QUESTIONS}"
    assert 1 <= MAX_GROUPS <= 4, \
        f"MAX_GROUPS 1-4 arasi olmali, mevcut: {MAX_GROUPS}"
    assert TEMPLATE_WIDTH > 0 and TEMPLATE_HEIGHT > 0, \
        "Template boyutlari pozitif olmali"
    assert QR_SIZE > 0 and QR_MARGIN >= 0, \
        "QR boyut ve margin gecerli olmali"
    assert BUBBLE_DIAMETER > 0 and BUBBLE_SPACING_X > 0 and ROW_HEIGHT > 0, \
        "Bubble grid sabitleri pozitif olmali"
    assert BUBBLE_CROP_MARGIN >= 0 and BUBBLE_CROP_MARGIN < BUBBLE_DIAMETER // 2, \
        f"BUBBLE_CROP_MARGIN 0-{BUBBLE_DIAMETER // 2} arasi olmali"
    assert BUBBLE_GRID_START_Y > 0, \
        "BUBBLE_GRID_START_Y pozitif olmali"


_validate_config()
