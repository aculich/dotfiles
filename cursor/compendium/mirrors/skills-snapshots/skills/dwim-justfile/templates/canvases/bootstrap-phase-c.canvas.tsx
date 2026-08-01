import {
  Button,
  Callout,
  Card,
  CardBody,
  CardHeader,
  H1,
  Stack,
  Text,
  TodoList,
  useCanvasAction,
  useCanvasState,
} from "cursor/canvas";

/** Stage detail canvas — Phase C inquiry. Copy beside overview when useful. */

export default function BootstrapPhaseC() {
  const dispatch = useCanvasAction();
  const [done, setDone] = useCanvasState("phase-c-checks", {
    exec: false,
    dossier: false,
    prd: false,
    praxis: false,
  });

  const todos = [
    { id: "exec", content: "EXECSUMMARY.md", status: done.exec ? ("completed" as const) : ("pending" as const) },
    { id: "dossier", content: "dossier/ USECASES LANDSCAPE ARCHITECTURE TECHSTACK SEARCH_KEYWORDS", status: done.dossier ? ("completed" as const) : ("pending" as const) },
    { id: "prd", content: "PRD.md for this tool only", status: done.prd ? ("completed" as const) : ("pending" as const) },
    { id: "praxis", content: "PRAXIS deepened (install waits for R)", status: done.praxis ? ("completed" as const) : ("pending" as const) },
  ];

  return (
    <Stack gap={16} style={{ padding: 24, maxWidth: 720 }}>
      <H1>Phase C — Inquiry + PRD</H1>
      <Callout tone="info" title="Agent phase">
        Use the button to open a chat with the Phase C brief. Do not write PLAYBOOK/FORKS yet.
      </Callout>
      <Card>
        <CardHeader>Checklist</CardHeader>
        <CardBody>
          <TodoList todos={todos} />
          <Button
            style={{ marginTop: 12 }}
            onClick={() => setDone({ exec: true, dossier: true, prd: true, praxis: true })}
          >
            Mark all complete
          </Button>
        </CardBody>
      </Card>
      <Button
        variant="primary"
        onClick={() =>
          dispatch({
            type: "newComposerChat",
            userPrompt:
              "Execute PHASES.md Phase C for this metarepo. Write EXECSUMMARY, dossier/*, PRD, deepen PRAXIS. Skip PLAYBOOK/FORKS. Then just tag-phase C.",
          })
        }
      >
        Start Phase C agent
      </Button>
      <Text tone="secondary">When done, mark C on bootstrap-overview and run just tag-phase C.</Text>
    </Stack>
  );
}
