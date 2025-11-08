### ISSUE
Generating a Blazor based custom element with .Net 10 RC2 has two points of failure.

### Is there an existing issue for this?

- [x] I have searched the existing issues

### Describe the bug

I am creating a Blazor based custom element and have run into several issues. I had a poorly written issue (#64807, now closed) that tried to detail my attempts with .Net 10 RC2. I believe the issues here are apart from the Mono assertion errors that are to be fixed in RTM.

The intent is to create a Blazor custom element that is hosted on a Vite website (so pretty much a javascript website).

Here are the issues encountered:

1. It appears that the generated blazor.webassembly.{version}.js has a hardcoded reference to dotnet.js (Observed in RC1 & RC2)
2. The publish output using RC2 is truncated.
3. Documentation needs a boost

Issues #1 & #2 prevent successful deployment of a Blazor based custom element using .Net 10 RC2.

Issue #3 is to help others avoid the trial and error I went through to get this working.

CC @guardrex Added because of documentation issues 

### Expected Behavior

I expect to be able to deploy a Blazor based custom element without a lot of trial and error

### Steps To Reproduce

I have created a sample project that demonstrates the issues. 
The project is ina public repository [CustomElementWASM](https://github.com/materia-technologies-inc/CustomElementWASM). There are detailed steps to reproduce
the issues in the ReadMe.md file. The main branch exhibits a working Blazor Custom Element with work-arounds for the two observed issues. There are two branches that exhibit the individual errors.

### Exceptions (if any)

None

### .NET Version

.Net 10 RC2

### Anything else?

_No response_