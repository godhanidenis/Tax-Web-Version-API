using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Data;
using System.Data.SqlClient;
using TMS_API.Dtos;

namespace TMS_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ManageHolderController : ControllerBase
    {
        SqlConnection sql;
        public ManageHolderController(IConfiguration configuration)
        {
            sql = new SqlConnection(configuration.GetConnectionString("DBConnection"));
        }

        [HttpGet]
        public async Task<DataSet> Get()
        {
            try
            {
                string query = "list_holder";
                SqlCommand cmd = new SqlCommand(query, sql);
                cmd.CommandType = CommandType.StoredProcedure;                
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

        [HttpPut]
        public async Task<DataSet> Put([FromForm] Holder holder)
        {
            try
            {
                string query = "edit_holder";
                SqlCommand cmd = new SqlCommand(query, sql);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@group_id", holder.group_id);
                cmd.Parameters.AddWithValue("@holder_id", holder.holder_id);
                cmd.Parameters.AddWithValue("@holder_name", holder.holder_name);
                cmd.Parameters.AddWithValue("@holder_email", holder.holder_email);
                cmd.Parameters.AddWithValue("@holder_phone", holder.holder_phone);
                cmd.Parameters.AddWithValue("@holder_status", holder.holder_status);
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
