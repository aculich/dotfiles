import {
  Button,
  Callout,
  Card,
  CardBody,
  CardHeader,
  Divider,
  H1,
  H2,
  H3,
  Pill,
  Row,
  Stack,
  Text,
  TodoList,
  useCanvasAction,
  useCanvasState,
  useHostTheme,
} from "cursor/canvas";

/**
 * Bootstrap overview control panel for a tool-quickstart metarepo.
 * Copy into the Cursor project canvases dir when opening the metarepo workspace:
 *   ~/.cursor/projects/<workspace>/canvases/bootstrap-overview.canvas.tsx
 * Machine steps stay on `just`; buttons open agent chats for C/D/R/AAR.
 */

const PHASE_PROMPTS = {
  C: "Read PHASES.md Phase C and execute it for this metarepo. Write EXECSUMMARY, dossier/*, PRD.md, deepen PRAXIS. Do not write PLAYBOOK/FORKS yet. Keep upstream/ gitignored.",
  D: "Read PHASES.md Phase D. Ensure just scaffold-lineages has been run (or run it). Write FORKS.md + PLAYBOOK.md. Attach-if-exists for public/personal/team remotes.",
  R: "Read PHASES.md Phase R. Create runtime.justfile with runtime-doit (do NOT rewrite envelope doit). Add flavor branding (bundle ID + UI name; disable Upstream Sparkle on private bundles). For Xcode apps include xcode-ready. Then just doit must hit runtime-doit. Update PRAXIS/PLAYBOOK. Tag with just tag-phase R when done.",
  AAR: "Run /bootstrap-aar for this metarepo. Enforce DoD: runtime.justfile + forks OK + just doit runtime path. Docs-only is not success.",
  DOIT: "In the metarepo root, run `just doit` and report the output. If thin Phase B only, continue to Phase R. Do not invent a happy path.",
};

export default function BootstrapOverview() {
  const theme = useHostTheme();
  const dispatch = useCanvasAction();
  const [status, setStatus] = useCanvasState("bootstrap-status", {
    A: "done" as const,
    B: "pending" as const,
    C: "pending" as const,
    D: "pending" as const,
    R: "pending" as const,
  });

  const todos = [
    { id: "A", content: "Phase A — envelope", status: status.A === "done" ? ("completed" as const) : ("pending" as const) },
    { id: "B", content: "Phase B — just doit (machine)", status: status.B === "done" ? ("completed" as const) : ("in_progress" as const) },
    { id: "C", content: "Phase C — inquiry + PRD (agent)", status: status.C === "done" ? ("completed" as const) : ("pending" as const) },
    { id: "D", content: "Phase D — lineages + PLAYBOOK", status: status.D === "done" ? ("completed" as const) : ("pending" as const) },
    { id: "R", content: "Phase R — runtime.justfile (required DoD)", status: status.R === "done" ? ("completed" as const) : ("pending" as const) },
  ];

  return (
    <Stack gap={20} style={{ padding: 24, maxWidth: 900 }}>
      <Stack gap={6}>
        <H1>Bootstrap overview</H1>
        <Text tone="secondary">
          Hybrid control: just for machine DWIM; buttons open Cursor agent chats for authoring phases.
          Docs-complete without runtime is not done.
        </Text>
      </Stack>

      <Callout tone="warning" title="Definition of done">
        Need runtime.justfile with runtime-doit, forks OK (or WITHOUT_TEAM), and just doit on the runtime path.
      </Callout>

      <Card>
        <CardHeader trailing={<Pill tone="info">phases</Pill>}>Progress</CardHeader>
        <CardBody>
          <TodoList todos={todos} />
          <Row gap={8} style={{ marginTop: 12, flexWrap: "wrap" }}>
            <Button
              onClick={() => setStatus((s) => ({ ...s, B: "done" }))}
            >
              Mark B done
            </Button>
            <Button
              onClick={() => setStatus((s) => ({ ...s, C: "done" }))}
            >
              Mark C done
            </Button>
            <Button
              onClick={() => setStatus((s) => ({ ...s, D: "done" }))}
            >
              Mark D done
            </Button>
            <Button
              onClick={() => setStatus((s) => ({ ...s, R: "done" }))}
            >
              Mark R done
            </Button>
          </Row>
        </CardBody>
      </Card>

      <H2>Agent phases</H2>
      <Row gap={8} style={{ flexWrap: "wrap" }}>
        <Button
          variant="primary"
          onClick={() =>
            dispatch({ type: "newComposerChat", userPrompt: PHASE_PROMPTS.C })
          }
        >
          Start Phase C
        </Button>
        <Button
          onClick={() =>
            dispatch({ type: "newComposerChat", userPrompt: PHASE_PROMPTS.D })
          }
        >
          Start Phase D
        </Button>
        <Button
          onClick={() =>
            dispatch({ type: "newComposerChat", userPrompt: PHASE_PROMPTS.R })
          }
        >
          Start Phase R
        </Button>
        <Button
          onClick={() =>
            dispatch({ type: "newComposerChat", userPrompt: PHASE_PROMPTS.AAR })
          }
        >
          Run /bootstrap-aar
        </Button>
      </Row>

      <H2>Machine</H2>
      <Row gap={8} style={{ flexWrap: "wrap" }}>
        <Button
          onClick={() =>
            dispatch({ type: "newComposerChat", userPrompt: PHASE_PROMPTS.DOIT })
          }
        >
          Ask agent to run just doit
        </Button>
        <Button
          onClick={() => dispatch({ type: "openFile", path: "justfile" })}
        >
          Open justfile
        </Button>
        <Button
          onClick={() => dispatch({ type: "openFile", path: "PHASES.md" })}
        >
          Open PHASES.md
        </Button>
        <Button
          onClick={() => dispatch({ type: "openFile", path: "PRAXIS.md" })}
        >
          Open PRAXIS.md
        </Button>
      </Row>

      <Divider />
      <H3>Optional regen</H3>
      <Text tone="secondary">
        Dual-laptop compare is optional. On another machine: /bootstrap-regen [stage] from
        metarepo/phase-*-done tags (just tag-phase after each phase).
      </Text>
      <Text tone="tertiary" style={{ color: theme.text.tertiary }}>
        Also update dossier/BOOTSTRAP_STATUS.md when completing a stage so peers see the same checklist.
      </Text>
    </Stack>
  );
}
