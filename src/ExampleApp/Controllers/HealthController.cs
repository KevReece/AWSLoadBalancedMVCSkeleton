using System.Web.Http;
using NLog;

namespace ExampleApp.ExampleApp.Controllers
{
    public class HealthController : ApiController
    {
        private readonly Logger log = LogManager.GetCurrentClassLogger();

        public IHttpActionResult Get()
        {
            log.Info("Api.Health.Get");
            return Ok("Health: OK");
        }
    }
}
