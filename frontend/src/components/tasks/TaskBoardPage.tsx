"use client";

import { useTeamsStore } from "@/stores/teams.store";
import TaskBoard from "./TaskBoard";

export default function TaskBoardPage({ teamId }: { teamId: string }) {
  const { teams } = useTeamsStore();
  const team = teams.find((t) => t.id === teamId);
  const teamName = team?.name ?? "Tasks";

  return <TaskBoard teamId={teamId} teamName={teamName} />;
}
