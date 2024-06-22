from configparser import ConfigParser
import os
import shutil
import subprocess
from tests.PrepareTest import PrepareTest

def run_python_script(script, on_succ, on_err):
	try:
		script()
	except SystemExit as e:
		on_err(e.code)
		exit(e.code)
	else:
		on_succ(0)

CONFIG = "config.conf"
sep = "-" * 50
sep_n = sep + "\n"

def Test():
	on_err = lambda code: print(f"{sep_n}An error occurred during build: {code}")
	on_succ = lambda code: None
	on_fin = lambda code: print(f"{sep_n}Build finished successfully.")
	
	quotes = r"\""
	config_parser = ConfigParser()
	config_parser.read(CONFIG)
	
	src_folder = config_parser["PATHS.INPUT"]["SRC_FOLDER"].strip(quotes)
	temp_test_folder = config_parser["TEST"]["TEMP_TEST_FOLDER"].strip(quotes)
	
	print(f"{sep_n}Preprocessing luau files for testing")
	
	run_python_script(lambda: PrepareTest(src_folder, temp_test_folder), on_succ, on_err)
	
	print(f"{sep_n}Executing tests.")
	if os.name == 'nt':
		command = ["binaries/windows/luau.exe", "tests/test.lua"]
	else:
		command = ["binaries/ubuntu/luau", "tests/test.lua"]
	
	subprocess.run(command, check=True)
	
	print(f"{sep_n}Testing finished successfully.")
	
	
	
	if os.path.exists(temp_test_folder):
		shutil.rmtree(temp_test_folder)
	

if __name__ == "__main__":
	Test()
