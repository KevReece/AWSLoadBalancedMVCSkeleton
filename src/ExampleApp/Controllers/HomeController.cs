using System.Web.Mvc;
using NLog;

namespace ExampleApp.ExampleApp.Controllers
{
    public class HomeController : Controller
    {
        private readonly Logger log = LogManager.GetCurrentClassLogger();

        public ActionResult Index()
        {
            log.Info("Home.Index");
            return View();
        }
    }
}