import MemberList from "@/components/members/MemberList";

export const metadata = { title: "Members — Task Board" };

export default async function MembersPage({ params }: { params: Promise<{ teamId: string }> }) {
  const { teamId } = await params;
  return <MemberList teamId={teamId} />;
}
