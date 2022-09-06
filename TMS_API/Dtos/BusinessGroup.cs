namespace TMS_API.Dtos
{
    public class BusinessGroup
    {
        public string group_name { get; set; }
        public string member_list { get; set; }
    }

    public class DeleteGroup
    {
        public int group_id { get; set; }
        public int member_id { get; set; }
    }

    public class AddGroupMember
    {
        public int group_id { get; set; }
        public string member_id { get; set; }
    }
}
