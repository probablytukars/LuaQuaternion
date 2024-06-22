# Contributing to LuaQuaternion

Thank you for considering contributing to LuaQuaternion. 

All contributions are welcome, from spelling corrections, to code improvements,
and new methods or support for external libraries and workflows.

# Setting up virtual environment and installing dependencies

To test code in this repository you will need python 3.x installed on your
computer. I have set up two files: `test.py` and `build.py` to allow for
easy testing and building of the website locally. To run these, you will
need to install the dependencies listed in `requirements.txt`. This can
be done simply using `pip install -r requirements.txt`. If you are editing
with visual studio code it may prompt you to create a virtual environment
to prevent conflicts with global installations. It is strongly recommended
you create a virtual environment to manage dependencies if you are using
python for other projects on your computer.

To create a virtual environment and install the required dependencies, you
can use the following commands:

- Unix (Linux/Mac):
`python -m venv .venv && ".venv/bin/python" -m pip install -r requirements.txt`

- Windows:
`python -m venv .venv && ".venv\Scripts\python" -m pip install -r requirements.txt`

# Testing

Once you have set up your virtual environment and installed the required
dependencies, you can test any changes you have made with the following
(assuming you are at the root of the project):

`python test.py`

This command will give you a detailed output of all tests completed,
as well as how many failed or encountered an unhandled exception.
At the end of the output, it will give you a summary, which includes
\[tests passed / number of tests \].
Before submitting a pull request, you should aim to have all tests pass,
otherwise it is likely your pull request will be rejected until the issue is
fixed.

# Building

You can also build the project, which in this case means the code will generate
the api website for the code, which you can inspect locally. Note that a
different build process is used locally compared to in the actions runner,
so be careful not to commit any build files to the repository - they are
already ignored in .gitignore, but always check. To build the website,
you can use the following command:

`python build.py`

And then if you open up the index.html file in your browser, you should be
able to see the website fully built locally. This way when you make changes
to the documentation you can easily see your changes reflected.


# Make a pull request

Once you have made your changes, and you are satisfied with them (and they
pass tests and build!) - open a pull request for the repository and your
request will reviewed. Please ensure your commit messages are clear and 
descriptive!
