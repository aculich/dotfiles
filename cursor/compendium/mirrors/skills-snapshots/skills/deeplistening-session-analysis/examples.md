# Examples — DeepListening session meta-analysis (L1)

## Canonical worked example — 2026-04-24 Aaron + Matt NLP-EMS session

This skill was derived from the 2026-04-24 session in the [`nlp-ems-paramedic`](/Users/me/projects/nlp-ems-paramedic/) project. Use the following outputs as the reference implementation.

### Evidence consumed

| Role | Path |
|---|---|
| VTT | [`evidence/zoom/2026-04-24_Aaron-Matt-NLP-EMS/02_TRANSCRIPT_audio_transcript.vtt`](/Users/me/projects/nlp-ems-paramedic/evidence/zoom/2026-04-24_Aaron-Matt-NLP-EMS/02_TRANSCRIPT_audio_transcript.vtt) |
| Granola | [`evidence/granola/545ad392_AaronMattNLPEMS_Apr242026/granola_private_notes_excerpt.xml`](/Users/me/projects/nlp-ems-paramedic/evidence/granola/545ad392_AaronMattNLPEMS_Apr242026/granola_private_notes_excerpt.xml) |
| Screenshare frames | [`evidence/zoom/2026-04-24_Aaron-Matt-NLP-EMS/processed_shared_screen/preview/`](/Users/me/projects/nlp-ems-paramedic/evidence/zoom/2026-04-24_Aaron-Matt-NLP-EMS/processed_shared_screen/preview/) |
| Gallery prelude still | [`evidence/zoom/2026-04-24_Aaron-Matt-NLP-EMS/processed_gallery/preview/prelude_gallery_both_speakers.jpg`](/Users/me/projects/nlp-ems-paramedic/evidence/zoom/2026-04-24_Aaron-Matt-NLP-EMS/processed_gallery/preview/prelude_gallery_both_speakers.jpg) |

### Outputs produced

| # | File | Size-ish |
|---|---|---|
| A1 | [`docs/deep-listening/2026-04-24-aaron-soundboard-critique.md`](/Users/me/projects/nlp-ems-paramedic/docs/deep-listening/2026-04-24-aaron-soundboard-critique.md) | ~217 lines |
| A2 | [`docs/deep-listening/2026-04-24-matt-standpoint-analysis.md`](/Users/me/projects/nlp-ems-paramedic/docs/deep-listening/2026-04-24-matt-standpoint-analysis.md) | ~217 lines |
| A3 | [`docs/deep-listening/2026-04-24-llm-as-soundboard-advice.md`](/Users/me/projects/nlp-ems-paramedic/docs/deep-listening/2026-04-24-llm-as-soundboard-advice.md) | ~168 lines |
| A4 | [`docs/deep-listening/2026-04-24-imagined-llm-dialog-with-matt.md`](/Users/me/projects/nlp-ems-paramedic/docs/deep-listening/2026-04-24-imagined-llm-dialog-with-matt.md) | ~236 lines |
| R | [`docs/deep-listening/README.md`](/Users/me/projects/nlp-ems-paramedic/docs/deep-listening/README.md) | index |

### Lineage + journal entries written

- [`.metacontext/lineage/2026-04-24-nlp-ems-matt-session.md`](/Users/me/projects/nlp-ems-paramedic/.metacontext/lineage/2026-04-24-nlp-ems-matt-session.md)
- [`.metacontext/journal/2026-04-24-reflexive-method-authoring.md`](/Users/me/projects/nlp-ems-paramedic/.metacontext/journal/2026-04-24-reflexive-method-authoring.md) (this is the L3 journal; the L1 work did not itself produce a separate journal because there was nothing to say about the method that the L3 pass wasn't already saying)

### What to notice when reading the worked example

1. **Every claim in A1 has a cue anchor.** Scan the trace table — `cue 283`, `cue 617`, `granola L1425-L1460` etc. Search for unanchored assertions; there are none. Match that bar.
2. **G1 / G2 / G3 is the first thing A1 explains.** The rest of the critique rests on that vocabulary. Do not skip.
3. **A2 leaves Aaron's voice out.** Re-read and notice you get a cleaner picture of Matt without facilitator overlay. The two artifacts complement rather than overlap.
4. **A3 is honest about where Aaron did better than the LLM would.** The brief avoids triumphalism — that is load-bearing for calibrating future LLM-as-soundboard work.
5. **A4's side-by-side table makes the gaps visible.** Look at the *"deictic resolution"* and *"landscape-spot"* rows especially.

## Typical invocation

A terse natural-language invocation is enough:

> "Analyze the 2026-05-01 session with Matt. Evidence is in `evidence/zoom/2026-05-01_Aaron-Matt-Checkin/` and `evidence/granola/*_AaronMatt_May012026/`. Write the L1 bundle to `docs/deep-listening/`."

The skill's description terms (analyze · session · soundboard critique · standpoint · L1) are triggers. The invocation above hits all of them.

## What the example does NOT show

- **Multi-session A2.** The 2026-04-24 A2 analyzes one session of Matt. A future pass with three sessions could produce a longitudinal standpoint reading across sessions — the skill as currently defined does not do that. If desired, invoke the skill once per session, then combine.
- **Failed invocation.** No canonical example exists of what the skill does when evidence is missing. Expected behavior: ask the user for the missing path, do not fabricate.
- **Non-English session.** Untested. The VTT reading and move-vocabulary assumption are English-centric. Flag this if invoked on another language.
