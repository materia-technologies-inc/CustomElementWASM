using CustomElementWASM;

using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;

var builder = WebAssemblyHostBuilder.CreateDefault(args);

// register the viewer component as a custom element
builder.RootComponents.RegisterCustomElement<BlazorMarkdigViewer>("blazor-markdig-viewer");

await builder.Build().RunAsync();
