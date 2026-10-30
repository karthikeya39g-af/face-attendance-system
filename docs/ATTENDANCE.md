# Attendance rules (all configurable)
Stored: first verified recognition of the day = check-in; a later scan after `MIN_MINUTES_BEFORE_CHECKOUT` = check-out; one row per employee per day.
Daily status is COMPUTED (not stored) by `compute_day`:
- check-in later than shift start + grace -> LATE (late minutes counted from shift start)
- worked = out - in - shift break (break only if the span is longer than the break)
- worked >= full-day minimum -> PRESENT/LATE; >= half-day minimum -> HALF_DAY; otherwise ABSENT (short hours)
- overtime = worked - required hours, only if it reaches the overtime threshold
- early checkout = out before shift end (minus tolerance)
- no check-in: HOLIDAY > WEEK_OFF > ON_LEAVE (approved) > ABSENT; today before shift start+grace = NOT_ARRIVED
- no check-out on a past day: policy `missing_checkout_policy` (assume full day / half day / absent), flagged for review
Defaults: week-off Sunday, full day 6 h, half day 4 h, overtime after 30 min, General shift 09:00-18:00, 60 min break, 15 min grace.
Overnight shifts are not supported.
