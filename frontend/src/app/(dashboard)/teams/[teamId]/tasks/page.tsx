import TaskBoardPage from "@/components/tasks/TaskBoardPage";

export const metadata = { title: "Tasks — Task Board" };

export default async function TasksRoute({ params }: { params: Promise<{ teamId: string }> }) {
  const { teamId } = await params;
  return <TaskBoardPage teamId={teamId} />;
}
