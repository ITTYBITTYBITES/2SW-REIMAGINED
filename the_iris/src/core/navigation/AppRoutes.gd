extends RefCounted
## AppRoutes - Route definitions
## Simplified launch flow: publisher splash -> title/loading -> home (main menu).
## First launch presents a centered Privacy & Terms modal over the loading screen,
## not a full-screen page. There is no multi-step onboarding.

const ROUTES := {
	# Launch sequence (splash/loading)
	"publisher_splash": {
		"screen": "PublisherSplashScreen",
		"is_tab": false,
		"requires_auth": false
	},
	"splash": {
		"screen": "TitleSplashScreen",
		"is_tab": false,
		"requires_auth": false
	},
	"title_splash": {
		"screen": "TitleSplashScreen",
		"is_tab": false,
		"requires_auth": false
	},
	"tutorial": {
		"screen": "TutorialScreen",
		"is_tab": false,
		"requires_auth": false
	},

	# Gameplay (launched from main menu)
	"observation": {
		"screen": "ObservationChallengeScreen",
		"is_tab": false,
		"requires_auth": false
	},
	"memory_question": {
		"screen": "MemoryQuestionScreen",
		"is_tab": false,
		"requires_auth": false
	},
	"result": {
		"screen": "ResultScreen",
		"is_tab": false,
		"requires_auth": false
	},

	# Primary app destinations. Phase 0 keeps route names stable while changing
	# player-facing hierarchy to Witness / Record / Settings. The Library route
	# remains available as a secondary destination, not a bottom tab.
	"home": {
		"screen": "HomeV2Screen",
		"is_tab": true,
		"requires_auth": false,
		"icon": "home",
		"label": "Witness"
	},
	"experiences": {
		"screen": "ExperiencesScreen",
		"is_tab": false,
		"requires_auth": false,
		"icon": "grid",
		"label": "Explore Experiences"
	},
	"profile": {
		"screen": "ProfileScreen",
		"is_tab": true,
		"requires_auth": false,
		"icon": "person",
		"label": "Record"
	},
	"settings": {
		"screen": "SettingsScreen",
		"is_tab": true,
		"requires_auth": false,
		"icon": "settings",
		"label": "Settings"
	},
	"about": {
		"screen": "AboutScreen",
		"is_tab": false,
		"requires_auth": false
	},
	"achievements": {
		"screen": "AchievementsScreen",
		"is_tab": false,
		"requires_auth": false
	},
	"programs": {
		"screen": "ProgramsScreen",
		"is_tab": false,
		"requires_auth": false
	},

}

const TAB_ORDER := ["home", "profile", "settings"]

# First-run is handled by a modal over the title/loading screen, not a routed flow.
const FIRST_RUN_FLOW: Array[String] = []

static func is_valid_route(route: String) -> bool:
	return ROUTES.has(route)

static func get_route(route: String) -> Dictionary:
	return ROUTES.get(route, {})

static func get_screen_name(route: String) -> String:
	return ROUTES.get(route, {}).get("screen", "")

static func is_tab_route(route: String) -> bool:
	return ROUTES.get(route, {}).get("is_tab", false)

static func get_tab_routes() -> Array:
	var tabs: Array = []
	for route in TAB_ORDER:
		if ROUTES.has(route):
			tabs.append(route)
	return tabs

static func is_first_run_route(_route: String) -> bool:
	# The privacy/tutorial full-screen pages are removed from the launch flow.
	# Remaining gameplay screens are standard routes, not first-run.
	return false
