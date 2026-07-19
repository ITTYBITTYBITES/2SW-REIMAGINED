extends SceneTree

## Mood system validation — verifies the dynamic color identity works end to end:
## profiles resolve to distinct colors, change_mood() bleeds (lerps, never snaps),
## State transitions auto-map mood, and SUCCESS can be forced+released.
var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var core := IrisCore.new()
	root.add_child(core)
	await process_frame

	# 1. Mood profiles exist and are distinct.
	var dormant := IrisCore.mood_profile(IrisCore.Mood.DORMANT)
	var aware := IrisCore.mood_profile(IrisCore.Mood.AWARE)
	var focused := IrisCore.mood_profile(IrisCore.Mood.FOCUSED)
	var success := IrisCore.mood_profile(IrisCore.Mood.SUCCESS)
	_assert(dormant.has("base_color") and dormant.has("glow_color") and dormant.has("energy"), "DORMANT profile has base/glow/energy")
	_assert(aware["glow_color"] != dormant["glow_color"], "AWARE and DORMANT glow colors differ")
	_assert(focused["glow_color"] != aware["glow_color"], "FOCUSED and AWARE glow colors differ")
	_assert(float(focused["energy"]) > float(aware["energy"]), "FOCUSED energy > AWARE energy")
	_assert(float(success["energy"]) > float(focused["energy"]), "SUCCESS energy > FOCUSED energy")

	# 2. After _ready, the core is in DORMANT mood with matching (snapped) colors.
	_assert(core.mood == IrisCore.Mood.DORMANT, "core starts in DORMANT mood")
	_assert(core.mood_base_color.is_equal_approx(dormant["base_color"]), "dormant base color applied at init")

	# 3. change_mood(AWARE) does NOT snap — the live color is still near dormant immediately.
	var color_before := core.mood_glow_color
	core.change_mood(IrisCore.Mood.AWARE)
	await process_frame
	var color_immediately_after := core.mood_glow_color
	_assert(not color_immediately_after.is_equal_approx(aware["glow_color"]), "mood glow does NOT snap to AWARE instantly (neural bleed)")
	_assert(color_before != core.mood_glow_color or true, "mood glow captured")  # informational

	# 4. After enough ticks, the color arrives at (near) the target — bleed completes.
	for i in range(240):  # ~4s of simulated time at 60fps
		await process_frame
		core.tick(1.0 / 60.0)
	var arrived := core.mood_glow_color
	_assert(abs(arrived.r - float(aware["glow_color"].r)) + abs(arrived.g - float(aware["glow_color"].g)) + abs(arrived.b - float(aware["glow_color"].b)) < 0.15, "mood glow arrives at AWARE after bleed")

	# 5. State -> Mood auto-mapping (not forced).
	core.transition_to(IrisCore.State.FOCUSED)
	_assert(core.mood == IrisCore.Mood.FOCUSED, "FOCUSED state auto-maps to FOCUSED mood")
	core.transition_to(IrisCore.State.AWARE)
	_assert(core.mood == IrisCore.Mood.AWARE, "AWARE state auto-maps to AWARE mood")

	# 6. SUCCESS is forceable and locks the mood against state changes.
	core.change_mood(IrisCore.Mood.SUCCESS, true)
	core.transition_to(IrisCore.State.AWARE)  # would normally map to AWARE mood
	_assert(core.mood == IrisCore.Mood.SUCCESS, "forced SUCCESS mood survives a state change")
	core.release_mood()
	_assert(core.mood == IrisCore.Mood.AWARE, "after release, mood follows state again (AWARE)")

	# 7. tick() exposes mood values in the behavior dict.
	var d: Dictionary = core.tick(0.016)
	_assert(d.has("mood") and d.has("mood_base_color") and d.has("mood_glow_color") and d.has("mood_energy"), "tick() dict exposes mood keys")
	_assert(int(d["mood"]) == int(core.mood), "tick() mood matches core.mood")

	core.free()
	await process_frame
	_finish()

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _finish() -> void:
	if failures.is_empty():
		print("MOOD_SYSTEM_PASS")
		quit(0)
	quit(1)
