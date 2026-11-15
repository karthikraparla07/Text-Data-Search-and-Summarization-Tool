# SCRIPTING WORKSHOP PROJECT REPORT

## Project 19: Text Data Search and Summarization Tool

**Course:** Scripting Workshop (SWS)  
**Student / Team Members:** [Enter names]  
**Roll Number(s):** [Enter roll numbers]  
**Institution:** [Enter institution]  
**Academic Year:** 2026–2027

## 1. Abstract

The Text Data Search and Summarization Tool is a command-line shell scripting application developed using Bash and core Linux text-processing utilities. It enables users to search text documents using regular expressions, clean basic HTML content and punctuation, calculate frequency counts, omit common stop words, and analyze sentence lengths. The project produces a structured report of text statistics and demonstrates practical use of `grep`, `sed`, `awk`, `sort`, and `head` in reusable scripts.

## 2. Problem statement

Large text datasets are difficult to inspect manually. Finding specific terms, identifying frequently occurring words, and computing basic readability statistics require repetitive work. This project automates these operations using simple Linux command-line tools.

## 3. Objectives

1. Search input text for patterns using `grep` and extended regular expressions.
2. Remove simple HTML tags and punctuation using `sed`.
3. Compute word frequencies and sentence-length statistics using `awk`.
4. Display the top N words in descending frequency order.
5. Allow stop-word removal so useful keywords appear prominently.
6. Export a reproducible summary report to a file.

## 4. Software and hardware requirements

**Software:** Ubuntu Linux or Ubuntu on WSL; Bash; standard GNU `grep`, `sed`, `awk`, `sort`, `head`, and `tee`.  
**Hardware:** Any laptop/desktop capable of running Ubuntu or WSL; no specialized hardware.

## 5. System architecture and workflow

1. User supplies a text-file path and selects an operation from `main.sh`.
2. Search: `search.sh` invokes `grep -Ein` to locate case-insensitive regex matches with line numbers.
3. Cleaning: `cleanup.sh` invokes `sed -E` to replace tags and punctuation with spaces.
4. Frequency: `summarize.sh` reads cleaned tokens using `awk`, excludes optional stop words, then sorts and limits the output.
5. Sentence statistics: `summarize.sh` uses `awk` to split punctuation-delimited sentences and compute count, minimum, maximum, and average length.
6. Report: the main script creates a timestamped report in the `output/` folder.

## 6. Algorithms

**Word frequency**

- Read and clean input text.
- Split each line into whitespace-separated tokens.
- Convert tokens to lowercase.
- Skip common words from `stopwords.txt` unless the user requests otherwise.
- Increment each word's count in an associative array.
- Sort counts in descending order and return the first N.

**Sentence statistics**

- Remove simple HTML tags while preserving sentence punctuation.
- Separate text at `.`, `!`, or `?`.
- Count words within each non-empty sentence.
- Compute number of sentences, total words, average words per sentence, and shortest/longest lengths.

## 7. Implementation

**`main.sh`:** Entry point with an interactive menu and direct command-line options.  
**`search.sh`:** Regular-expression matching via GNU grep.  
**`cleanup.sh`:** Text normalization using GNU sed.  
**`summarize.sh`:** Word statistics, stop-word removal, sentence analysis, and report content via awk.  
**`stopwords.txt`:** Configurable list of common English words.  
**`tests/test_project.sh`:** Automated functional checks of all major operations.

## 8. Testing and results

Test data: `data/sample.txt`, an original short sample about a university digital library.

Expected sample observations:

| Metric | Result |
|---|---:|
| Total words | 85 |
| Unique words | 53 |
| Sentences | 10 |
| Average sentence length | 8.50 words |
| Frequency of "students" (stop words removed) | 7 |
| Frequency of "library" (stop words removed) | 5 |
| Frequency of "research" (stop words removed) | 4 |

The automated test script checks cleanup, regex matching, no-match behavior, word-frequency counts, stop-word removal, sentence counts, report creation, and invalid input handling.

**Insert the following real screenshots after running the project in Ubuntu:**

- Screenshot 1: Main menu
- Screenshot 2: grep search result
- Screenshot 3: sed text-cleaning result
- Screenshot 4: awk word-frequency table
- Screenshot 5: stop-word option comparison
- Screenshot 6: sentence-length statistics
- Screenshot 7: generated final report
- Screenshot 8: passing test results

## 9. Advantages

- Uses commonly available Linux utilities without external libraries.
- Runs locally and does not upload data to a server.
- Supports user-selected text files and Top N limits.
- Simple modular scripts are easy to update and understand.
- Automated testing improves reliability.

## 10. Limitations and future enhancements

- Sentence splitting uses punctuation heuristics and does not fully understand abbreviations.
- HTML cleanup does not parse advanced or malformed web pages.
- Unicode word handling depends on installed locale and tools.
- Future improvements could include processing folders of files, CSV/JSON export, better multilingual tokenization, and visualizations.

## 11. Conclusion

This project demonstrates how Bash scripting and standard Linux commands can automate practical text processing. Its modular implementation performs search, cleaning, word-frequency statistics, stop-word filtering, and sentence-length analysis, meeting the project's specified core requirements.

## 12. References

- GNU grep manual: https://www.gnu.org/software/grep/manual/
- GNU sed manual: https://www.gnu.org/software/sed/manual/
- GNU awk manual: https://www.gnu.org/software/gawk/manual/
- Bash manual: https://www.gnu.org/software/bash/manual/

## Functional Browser Prototype
The project includes a responsive interactive dashboard (`prototype.html`) run by `server.py` and `start_prototype.sh`. Users can upload a dataset, search regular-expression patterns, review word-frequency bars, calculate sentence statistics, preview cleaned text and export an analysis report. The Python standard-library HTTP server provides the interface while shell scripts handle text processing with grep, awk and sed. This demonstrates a functional interface built on the mandatory Linux commands, rather than a static design.
