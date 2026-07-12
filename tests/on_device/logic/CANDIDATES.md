# On-Device Unit Test Candidates

Every claim below was checked directly against this repository's real
source at the current HEAD (`grep`/`wc -l` on the actual `.c` files), not
inferred from app names. None of these functions have been compiled or
executed as an on-device unit test in this phase — this is a source-read
audit identifying *candidates*, not a working test suite.

## Confirmed pure-logic candidates (real function names verified)

### `resistors` (real appid `resistance_calculator`)

`applications_user/resistors/src/resistor_logic.c` (314 lines) contains
genuinely separated, side-effect-free logic functions, e.g.:

```
bool has_tolerance(ResistorType rtype)
bool has_temp_coeff(ResistorType rtype)
bool is_numeric_band(ResistorType rtype, int index)
bool is_multiplier_band(ResistorType rtype, int index)
bool is_tolerance_band(ResistorType rtype, int index)
bool is_temp_coefficient_band(ResistorType rtype, int index)
bool is_numeric_colour(BandColour colour)
bool is_multiplier_colour(BandColour colour)
bool is_tolerance_colour(BandColour colour)
bool is_temp_coeff_colour(BandColour colour)
```

These are strong candidates: pure boolean classifiers over small enums,
directly unit-testable with a table of (input, expected) pairs and no
UI/hardware dependency at all.

### `network_subnet`

`applications_user/network_subnet/core/subnet_math.c` (58 lines) is
already separated from the UI/scene code into its own file, containing:

```
uint8_t count_number_of_continuous_ones(uint32_t subnet_number)
void subnet_calculate(...)
```

Strong candidate: subnet-mask bit-counting and CIDR arithmetic are
exactly the kind of boundary-condition-rich logic (0, 32, non-contiguous
masks) that benefits from headless unit tests.

### `vin_decoder`

`applications_user/vin_decoder/vin_decoder.c` is a single 2,213-line
file with UI and logic intermixed (not yet separated into its own logic
module). It does contain one clearly pure, testable function:

```
const char* get_vehicle_manufacturer(const char* vin)
```

a linear lookup against a static `manufacturers[]` table matching the
VIN's first 3 characters (WMI code). **Correction to an earlier internal
assumption**: this file was checked directly for a checksum/check-digit
function (`grep -n "checksum\|check_digit"`) and none exists - VIN ISO
3779 check-digit validation is not implemented by this app. The only
confirmed testable logic is the manufacturer-prefix lookup above.

## Plausible but unverified in this phase

- `quadratic_solver` — very likely contains pure root-finding arithmetic,
  but the specific function name/signature has not been read yet.
- `programmer_calc` (`programmercalc`) — very likely contains pure
  base-conversion arithmetic, not yet read.
- `crypto_dictionary` (`crypto_dict`) — likely a static lookup table
  similar to `vin_decoder`'s manufacturer table; not yet read.
- `hex_viewer`, `docviewlite`, `image_viewer` — file-format parsing
  boundary conditions are plausible unit-test candidates once paired
  with real, license-clear fixture files, but the parsing code itself
  has not been read in this phase.

**Do not treat the "plausible but unverified" list as equivalent in
confidence to the "confirmed" list above** - the distinction is
deliberate and should be preserved in any later phase that acts on this
document.

## Assessed and found not to be strong candidates (yet)

- `chess`, `sudoku`, `2048`, `minesweeper_redux` — these almost certainly
  contain testable state-machine logic (move validation, win/loss
  detection, board invariants), but none of their source was read in
  this phase to confirm function-level separation from UI code. Treat as
  unassessed, not as confirmed candidates, until a real source read is
  done.

## Why this matters for the vNext test strategy

The two confirmed candidates above (`resistor_logic.c`,
`subnet_math.c`) are proof that at least some of this project's own
imported apps already separate logic from UI cleanly enough to unit-test
headlessly - this is a genuine, verifiable data point for
`docs/architecture/rfc-1-custom-app-health-center.md`'s test-status
tracking, not an aspirational claim.
