using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Data;
using System.Data.SqlClient;

namespace TMS_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ConnectionCheckController : ControllerBase
    {
        SqlConnection sql;
        public ConnectionCheckController(IConfiguration configuration)
        {
            sql = new SqlConnection(configuration.GetConnectionString("DBConnection"));
        }

        [HttpGet]
        public async Task<string> Get()
        {            
            try
            {
                string query = "select * from dbo.test";
                SqlCommand cmd = new SqlCommand(query, sql);
                await sql.OpenAsync();
                SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                DataSet ds = new DataSet();
                adapter.Fill(ds);
                if (ds.Tables[0].Rows.Count > 0)
                    return "Database Connected Successfully";
                else
                    return "Databas Not Connected";
            }
            catch(Exception ex)
            {
                return ex.Message.ToString();
            }
            finally
            {
                sql.Close();
            }            
        }
    }
}
