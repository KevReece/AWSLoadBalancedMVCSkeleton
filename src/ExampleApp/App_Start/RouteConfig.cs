using System.Web.Mvc;
using System.Web.Routing;

namespace ExampleApp.ExampleApp
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute(
                name: "Default",
                url: "{clientId}",
                defaults: new { controller = "Home", action = "Index", clientId = UrlParameter.Optional }
            );
        }
    }
}
