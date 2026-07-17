extends SceneTree

func _init() -> void:
    print("==================================================")
    print(" 2SW 4.0 AUTOMATED REGRESSION SUITE (HEADLESS)")
    print("==================================================")
    
    var failed := false
    
    # 1. Verify Core Scenes Exist
    print("\n[1] Verifying Core Scenes...")
    var core_scenes = [
        "res://scenes/Main.tscn",
        "res://scenes/Iris.tscn",
        "res://src/ui/screens/ExperienceReadinessScreen.tscn",
        "res://src/ui/screens/WitnessObservationScreen.tscn",
        "res://src/ui/screens/WitnessReconstructionScreen.tscn",
        "res://src/ui/screens/WitnessInvestigationScreen.tscn",
        "res://src/ui/screens/WitnessRevelationScreen.tscn"
    ]
    for path in core_scenes:
        if ResourceLoader.exists(path):
            print("  [OK] " + path)
        else:
            print("  [FAIL] Missing " + path)
            failed = true

    # 2. Verify Incident Registry Data Integrity
    print("\n[2] Verifying Incident Registry Manifest...")
    var IncidentRegistryClass = load("res://src/iris/story/registry/IncidentRegistry.gd")
    if IncidentRegistryClass:
        var registry = IncidentRegistryClass.new()
        registry.reload()
        if registry._invalid_ids.size() == 0 and registry._load_order.size() > 0:
            print("  [OK] Incident Registry loaded " + str(registry._load_order.size()) + " incidents without validation errors.")
        else:
            print("  [FAIL] Incident Registry had " + str(registry._invalid_ids.size()) + " invalid incidents.")
            failed = true
        registry.free()
    else:
        print("  [FAIL] Could not load IncidentRegistry.")
        failed = true

    # 3. Verify Witness Director Content Matrix
    print("\n[3] Verifying Witness Director Content Matrix...")
    var DirectorClass = load("res://src/iris/story/WitnessExperienceDirector.gd")
    if DirectorClass:
        var director = DirectorClass.new()
        director._load_moments()
        if director.moments.size() >= 10:
            print("  [OK] Director correctly mapped " + str(director.moments.size()) + " witness moments (Chapters 1 & 2).")
        else:
            print("  [FAIL] Director only mapped " + str(director.moments.size()) + " moments.")
            failed = true
        director.free()
    else:
        print("  [FAIL] Could not load WitnessExperienceDirector.")
        failed = true

    print("\n==================================================")
    if failed:
        print(" REGRESSION SUITE FAILED.")
        quit(1)
    else:
        print(" REGRESSION SUITE PASSED.")
        quit(0)
