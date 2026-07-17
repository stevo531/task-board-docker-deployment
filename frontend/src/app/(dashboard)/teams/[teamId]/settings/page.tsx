import TeamSettingsContent from "@/components/teams/TeamSettingsContent";

export const metadata = { title: "Team Settings — Task Board" };

export default async function TeamSettingsPage({ params }: { params: Promise<{ teamId: string }> }) {
  const { teamId } = await params;
  return <TeamSettingsContent teamId={teamId} />;
}
