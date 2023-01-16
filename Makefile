clean:
	rm -rf build

localdev:
	sphinx-build -b html docs build
