using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Data;
using System.Data.SqlClient;
using TMS_API.Dtos;

namespace TMS_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ManageGroupController : ControllerBase
    {
        SqlConnection sql;
        public ManageGroupController(IConfiguration configuration)
        {
            sql = new SqlConnection(configuration.GetConnectionString("DBConnection"));
        }

        [HttpGet("{group_id}")]
        public async Task<DataSet> Get(int group_id)
        {
            try
            {
                string query = "list_group";
                SqlCommand cmd = new SqlCommand(query, sql);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@group_id", group_id);
                await sql.OpenAsync();
                SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                DataSet ds = new DataSet();
                adapter.Fill(ds);
                return ds;
            }
            catch (Exception ex)
            {
                DataSet ds = new DataSet(ex.Message.ToString());
                ds.AcceptChanges();
                return ds;
            }
            finally
            {
                sql.Close();
            }
        }

        [HttpPost]
        [Route("client")]
        public async Task<DataSet> client([FromForm] ClientGroup clientGroup)
        {
            try
            {
                string query = "create_group";
                SqlCommand cmd = new SqlCommand(query, sql);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@holder_name", clientGroup.holder_name);
                cmd.Parameters.AddWithValue("@holder_email", clientGroup.holder_email);
                cmd.Parameters.AddWithValue("@holder_phone", clientGroup.holder_phone);
                cmd.Parameters.AddWithValue("@group_type", clientGroup.group_type);
                cmd.Parameters.AddWithValue("@reference_id", clientGroup.reference_id);
                await sql.OpenAsync();
                SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                DataSet ds = new DataSet();
                adapter.Fill(ds);
                return ds;
            }
            catch (Exception ex)
            {
                DataSet ds = new DataSet(ex.Message.ToString());
                ds.AcceptChanges();
                return ds;
            }
            finally
            {
                sql.Close();
            }
        }        

        [HttpPost]
        [Route("business")]
        public async Task<DataSet> business([FromForm] BusinessGroup businessGroup)
        {
            try
            {
                string query = "create_business";
                SqlCommand cmd = new SqlCommand(query, sql);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@group_name", businessGroup.group_name);
                cmd.Parameters.AddWithValue("@member_list", businessGroup.member_list);
                await sql.OpenAsync();
                SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                DataSet ds = new DataSet();
                adapter.Fill(ds);
                return ds;
            }
            catch (Exception ex)
            {
                DataSet ds = new DataSet(ex.Message.ToString());
                ds.AcceptChanges();
                return ds;
            }
            finally
            {
                sql.Close();
            }
        }

        [HttpDelete("{group_id}/{member_id}")]
        public async Task<DataSet> Delete(int group_id, int member_id)
        {
            try
            {
                string query = "delete_member";
                SqlCommand cmd = new SqlCommand(query, sql);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@group_id", group_id);
                cmd.Parameters.AddWithValue("@member_id", member_id);
                await sql.OpenAsync();
                SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                DataSet ds = new DataSet();
                adapter.Fill(ds);
                return ds;
            }
            catch (Exception ex)
            {
                DataSet ds = new DataSet(ex.Message.ToString());
                ds.AcceptChanges();
                return ds;
            }
            finally
            {
                sql.Close();
            }
        }

        [HttpPut("{group_id}")]
        public async Task<DataSet> Put(int group_id)
        {
            try
            {
                string query = "edit_group_status";
                SqlCommand cmd = new SqlCommand(query, sql);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@group_id", group_id);
                await sql.OpenAsync();
                SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                DataSet ds = new DataSet();
                adapter.Fill(ds);
                return ds;
            }
            catch (Exception ex)
            {
                DataSet ds = new DataSet(ex.Message.ToString());
                ds.AcceptChanges();
                return ds;
            }
            finally
            {
                sql.Close();
            }
        }

        [HttpPost]
        [Route("add_member")]
        public async Task<DataSet> add_member([FromForm] AddGroupMember addGroupMember)
        {
            try
            {
                string query = "add_member";
                SqlCommand cmd = new SqlCommand(query, sql);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@group_id", addGroupMember.group_id);
                cmd.Parameters.AddWithValue("@member_id", addGroupMember.member_id);
                await sql.OpenAsync();
                SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                DataSet ds = new DataSet();
                adapter.Fill(ds);
                return ds;
            }
            catch (Exception ex)
            {
                DataSet ds = new DataSet(ex.Message.ToString());
                ds.AcceptChanges();
                return ds;
            }
            finally
            {
                sql.Close();
            }
        }
    }
}
