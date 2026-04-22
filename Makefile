all: analyzer

analyzer: analyzer.s
	gcc -o analyzer analyzer.s

clean:
	rm -f analyzer
