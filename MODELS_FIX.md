Fix the modelfiles to use the tools correctly with Opencode by adding the necessary tools definitions in the `SYSTEM` section. 
Test all the modules in `./models` directory. Don't ever touch in other sections of the file.
To help you test, here are helpful commands:

```bash
ollama rm <name>:latest
ollama create <name>:latest -f models/Modelfile.<name>
opencode run "Create a file called capital.txt and add the capital of the USA in uppercase. Just the city name!" --model ollama/<name>:latest
[[ "$(cat capital.txt)" == "WASHINGTON" ]] && echo "Test passed!" || echo "Test failed!"
opencode run "Create a python script that reverses the string 'Manoel' and add the file 'manoel.py'" --model ollama/<name>:latest
[[ "$(python3 manoel.py)" == "leonaM" ]] && echo "Test passed!" || echo "Test failed!"
```

Make sure that the `opencode` has all the permissions to run those tools.

After this extensive test, the latest step is to pass the `scripts/test-models.sh` run.