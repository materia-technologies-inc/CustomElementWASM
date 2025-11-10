# ReadMe

## Prerequisites
Before building and running this project, ensure you have the following prerequisites installed on your machine:
- [.NET 10 SDK RC2](https://dotnet.microsoft.com/en-us/download/dotnet/10.0)
- [Node.js (version 16 or later)](https://nodejs.org/)
- [pnpm package manager](https://pnpm.io/installation) (You can install it globally using npm: `npm install -g pnpm`)
- [deno](https://deno.land/#installation) (You can install it using the command: `curl -fsSL https://deno.land/install.sh | sh`)

## Building and Running the Project

To build and run this project, follow these steps:
1. **Clone the Repository**: Start by cloning the repository to your local machine using the following command:
   ```
   git clone https://github.com/materia-technologies-inc/CustomElementWASM.git
   ```
2. Using a powershell prompt, navigate to the solution directory:
   ```
   cd CustomElementWASM
   ``` 
3. Do an install of the npm packages:
   ```
   pnpm install
   ```
4. Run the following command to build the project:
   ```
   pnpm build
   ``` 
5. Run the following command to run the project:
   ```
   pnpm dev
   ``` 
6. In a browser, navigate to `http://localhost:7305` to see the project in action.
 
## Demonstrating RC1/RC2 BlazorWebassembly.js issue

- In RC1 & RC2, the generated `blazor.webassembly.{version}.js` apparently has a hardcoded reference to `dotnet.js`, which leads to failure when deploying the custom element.

- To demonstrate this, switch to the `rc1rc2-hard-code` branch:
   ```
   git checkout rc1rc2-hard-code
   ```
   Then follow the build and run steps above. You will notice that the custom element fails to load due to the hardcoded reference. In broser dev tools just look at the network tab and you will see a failure loading dotnet.js.

