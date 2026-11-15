# Text Data Search and Summarization Tool

**Scripting Workshop — Project 19**

A Bash terminal application for searching text files, cleaning text, counting words, analyzing sentence lengths, and saving summary statistics. Designed for Ubuntu Linux and Windows Subsystem for Linux (WSL).

## Project requirements and implementation

| Requirement | Implementation |
|---|---|
| `grep` for regex pattern matching | `search.sh`: `grep -Ein` with line numbers and case-insensitive extended regex |
| `awk` for word frequency | `summarize.sh`: word counting, stop-word filtering, sorting |
| `awk` for sentence length | `summarize.sh`: sentence count, average, minimum and maximum word lengths |
| `sed` for text cleanup | `cleanup.sh`: simple HTML tags, common HTML entities, punctuation |
| Top N words and counts | User-selectable N, default 10 |
| Stop-word removal | Editable `stopwords.txt`, with option to retain stop words |

## Files

```
Text_Data_Search_and_Summarization_Tool/
├── main.sh                 # Menu and command-line interface
├── search.sh               # grep regex search
├── cleanup.sh              # sed cleanup
├── summarize.sh            # awk statistics and summary report
├── stopwords.txt           # Default common English stop words
├── data/
│   └── sample.txt          # Sample input dataset
├── output/                 # Saved reports
├── tests/
│   └── test_project.sh     # Automated checks
├── PROJECT_REPORT.md       # Project report draft
└── README.md
```

## Setup on Ubuntu / WSL

1. Extract the ZIP archive anywhere under your Linux home directory, e.g. `~/`.
2. Open Ubuntu and type:

   ```bash
   cd ~/Text_Data_Search_and_Summarization_Tool
   chmod +x main.sh search.sh cleanup.sh summarize.sh tests/test_project.sh
   ./main.sh
   ```

If your ZIP was extracted to Windows Downloads, you can copy the project folder from `/mnt/c/Users/YOUR_WINDOWS_USERNAME/Downloads/` into your Linux home folder, or use the VS Code file explorer. Replace `YOUR_WINDOWS_USERNAME` with your actual username.

## Quick demonstration

Run these commands from the project folder:

```bash
./main.sh search data/sample.txt 'library|research'
./main.sh clean data/sample.txt
./main.sh frequency data/sample.txt 10
./main.sh frequency data/sample.txt 10 --keep-stopwords
./main.sh sentences data/sample.txt
./main.sh report data/sample.txt 10
./tests/test_project.sh
```

To analyze a different file, put it in `data/` and specify its path, e.g. `./main.sh report data/novel.txt 20`.

### Menu choices

1. Search for words or regex patterns.
2. Clean text (remove tags and punctuation).
3. Calculate Top N most frequent words with optional stop-word removal.
4. Calculate sentence statistics.
5. Generate and save a report in `output/`.
6. Exit.

## Example output from `data/sample.txt`

```text
Total words (including stop words): 85
Unique words (including stop words): 53
Sentences: 10
Average sentence length: 8.50 words

WORD       COUNT
students   7
library    5
research   4
data       3
digital    3
university 3
```

## Screenshots for project submission

Capture these in an Ubuntu terminal:

1. `ls -l` showing executable scripts.
2. `./main.sh` menu.
3. `./main.sh search data/sample.txt 'library|research'` demonstrating grep.
4. `./main.sh clean data/sample.txt` demonstrating sed.
5. `./main.sh frequency data/sample.txt 10` demonstrating awk word counts.
6. `./main.sh frequency data/sample.txt 10 --keep-stopwords` to contrast stop-word filtering.
7. `./main.sh sentences data/sample.txt` demonstrating sentence analysis.
8. `./main.sh report data/sample.txt 10` showing saved report.
9. `./tests/test_project.sh` showing automated test results.

## Notes / limitations

- Basic English/plain-text analysis; word tokenization counts alphanumeric groups containing letters. Numbers alone are excluded from word frequency.
- `grep -E` supports extended regex; use `library|research` to match either word.
- HTML cleaning is designed for simple markup, not a full multi-line HTML parser or nested script/style removal.
- Sentence boundaries are approximated by `.`, `!`, `?`; abbreviations and decimals may be split incorrectly. Text without final punctuation is counted as a sentence.
- The tool summarizes **statistics**, not abstract meaning or AI-generated summaries.
- Input files are read, not modified. Report files are stored under `output/`.

## Interactive browser prototype (recommended for demonstration)

This project also includes **TextScope**, a browser-based visual prototype with a dashboard, text upload, regex search, word-frequency charts, sentence statistics, cleanup preview, and downloadable report. Unlike a static mockup, it uses the actual Bash scripts (`grep`, `awk`, `sed`) through a small Python standard-library server.

On Ubuntu / WSL (Python 3 required):

```bash
cd ~/Text_Data_Search_and_Summarization_Tool
chmod +x *.sh
./start_prototype.sh
```

Open **http://localhost:8000** in your Windows or Linux web browser. The server works only on your computer (127.0.0.1). Press **Ctrl+C** in Ubuntu to stop it.

Select **Load sample** to demonstrate the application, or upload a `.txt` / `.html` file (maximum 2 MB). Use the left menu to switch between features.

If port 8000 is busy: `python3 server.py --port 8001`, then visit `http://localhost:8001`.
