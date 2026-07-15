# Flash Words

Production Challenge Type implemented entirely through established Game and Content extension points.

## Templates

- `single_word_v1`
- `word_pair_order_v1`
- `word_stream_presence_v1`

## Family modules

- `FlashWordsFamily.gd`
- `FlashWordsGenerator.gd`
- `FlashWordsValidator.gd`
- `FlashWordsDifficultyPolicy.gd`
- `FlashWordsExposurePolicy.gd`
- `FlashWordsScoringPolicy.gd`
- `FlashWordsSceneView.gd`
- `tutorial/FlashWordsTutorial.tscn`

## Content

- 373 reviewed English words with balancing metadata
- Three template definitions
- Flash Words preview artwork
- Rhythmic understated audio cues

## Architecture boundary

No Core, Systems, shared UI, shared runtime, contract, navigation, or project file may be changed for Flash Words. `verify_flash_words_engine_unchanged.py` enforces the protected baseline.
