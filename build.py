import os
from sys import argv
from configparser import ConfigParser
from docs.JSON import JSON
from docs.HTML import HTML

CONFIG = "config.conf"
sep = "-" * 50
sep_n = sep + "\n"

def run_python_script(script, on_succ, on_err):
	try:
		script()
	except SystemExit as e:
		on_err(e.code)
		exit(e.code)
	else:
		on_succ(0)


def Build():
	argc = len(argv)
	
	if argc > 2:
		print("Invalid number of arguments passed into build. Expected a maximum of 1 argument.")
	
	quotes = r"\""
	config = ConfigParser()
	config.read(CONFIG)
	
	input_paths = config["PATHS.INPUT"]
	output_paths = config["PATHS.OUTPUT"]
	web = config["WEB"]
	
	src_path = input_paths["SRC_FOLDER"].strip(quotes)
	read_me_path = input_paths["READ_ME_PATH"].strip(quotes)
	template_html_path = input_paths["TEMPLATE_HTML_PATH"].strip(quotes)
	
	build_path = output_paths["BUILD_PATH"].strip(quotes)
	json_path = output_paths["JSON_PATH"].strip(quotes)
	api_path = output_paths["API_PATH"].strip(quotes)
	
	web_path = None
	index_html = ""
	
	if argc > 1 and argv[1] == "true":
		web_path = web["ACTIONS_WEB_PATH"].strip(quotes)
	else:
		local_web_path = os.path.join(build_path, web["LOCAL_WEB_PATH"].strip(quotes))
		web_path = "file:///" + os.path.abspath(local_web_path).replace("\\", "/") + "/"
		index_html = "index.html"
	
	on_err = lambda code: print(f"{sep_n}An error occured during build: {code}")
	on_succ = lambda code: print(f"{sep}")
	on_fin = lambda code: print(f"{sep_n}Build finished successfully.")
	
	print(sep)
	run_python_script(
		lambda: JSON(src_path, build_path, json_path), 
		on_succ, 
		on_err
	)
	
	run_python_script(
		lambda: HTML(read_me_path, template_html_path, build_path, web_path, index_html), 
		on_fin, 
		on_err
	)

if __name__ == "__main__":
	Build()




