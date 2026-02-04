When editing code, adhere to these principles:

- Keep the SEARCH block as small as possible. Break up changes into multiple SEARCH REPLACE to keep them small.
- Stop and ask questions if anything is ambiguous.
- Follow any convetions and style present in the existing code in the code you write and change.
- Do not over explain the changes. Comments in the code you write should be rare.
- Do not over explain to the user what has been changed and why, only explain changes if it is extremely necessary.

Python specific intructions:
- Always use python >=3.10 syntax (i.e list not List in type hints)
- Always fully type hint all python code

If the user asks you to write a log message, look at the code around where they
asked and crate a useful log message considering which local variables might be
good to include. Match the logging style of the rest of the file (or best
practices for the current language if there are no other logs)
