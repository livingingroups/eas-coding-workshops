# Running Multistep Processes with Command Line

## About

### Attribution/License

This content is a remix of The Carpentries Lesson [The Unix Shell](https://swcarpentry.github.io/shell-novice/) episodes 3, 4, and 6 released and used under [CC-BY](https://swcarpentry.github.io/shell-novice/LICENSE.html). This lesson was lightly remixed by Katrina Brock and the remix is not endorsed by The Carpentries. Summary of changes can be found [here](./remix-summary.md)

### Objectives and Questions

In this workshop, we'll start by reviewing basic file and directory manipulation commands.
Then, we'll learn how to put these commands together.

<details> <summary> Learning Objectives </summary>

Pipes and filters:

- Explain the advantage of linking commands with pipes and filters.
- Combine sequences of commands to get new output
- Redirect a command's output to a file.
- Explain what usually happens if a program or pipeline isn't given any input to process.

Shell scripts:

- Write a shell script that runs a command or series of commands for a fixed set of files.
- Run a shell script from the command line.
- Write a shell script that operates on a set of files defined by the user on the command line.
- Create pipelines that include shell scripts you, and others, have written.

</details>

<details> <questions> Learning Objectives </questions>
- How can I combine existing commands to produce a desired output?
- How can I show only part of the output?
- How can I save and re-use commands?
</details>


## Review

### Overview of Last Week's Material

Commands

- `pwd`
- `ls`
- `cd`
- `pwd`
- `man`
- `nano`
- `touch`
- `mv`

Syntax

- What does the `$` indicate?
- What characters do we use to separate different parts of a command?
- (For example, in many programing languages, you have something like `function_name(unnamed_argument, argument_name = argument_value)` so `(` separates the function name from arguments and `,` separates arguemnts from each other. How does this works with shell?)
- How do we get information about a command?


### Review: Moving Files

### :muscle: Challenge

### Moving Files to a new folder

After running the following commands,
Jamie realizes that she put the files `sucrose.dat` and `maltose.dat` into the wrong folder.
The files should have been placed in the `raw` folder.

```bash
$ ls -F
analyzed/ raw/
$ ls -F analyzed
fructose.dat glucose.dat maltose.dat sucrose.dat
$ cd analyzed
```

Fill in the blanks to move these files to the `raw/` folder
(i.e. the one she forgot to put them in)

```bash
$ mv sucrose.dat maltose.dat ____/____
```

<details> <summary>View Solution...</summary>

### Solution

```bash
$ mv sucrose.dat maltose.dat ../raw
```

Recall that `..` refers to the parent directory (i.e. one above the current directory)
and that `.` refers to the current directory.

</details>

### Review: Learning about a new command (`cp`)

`cp` is the command to copy files. If we don't know how to use it, what should we do?

```bash
???
```

```output
cp --help
Usage: cp [OPTION]... [-T] SOURCE DEST
or:  cp [OPTION]... SOURCE... DIRECTORY
or:  cp [OPTION]... -t DIRECTORY SOURCE...
Copy SOURCE to DEST, or multiple SOURCE(s) to DIRECTORY.

Mandatory arguments to long options are mandatory for short options too.
-a, --archive                same as -dR --preserve=all
--attributes-only        don't copy the file data, just the attributes
--backup[=CONTROL]       make a backup of each existing destination file
-b                           like --backup but does not accept an argument
--copy-contents          copy contents of special files when recursive
-d                           same as --no-dereference --preserve=links
--debug                  explain how a file is copied.  Implies -v
-f, --force                  if an existing destination file cannot be
opened, remove it and try again (this option
is ignored when the -n option is also used)
```

How do we interpret the `Usage:` section?

How do we interpret the section that starts `Mandatory arguments to...`?


The `cp` command works very much like `mv`,
except it copies a file instead of moving it.
We can check that it did the right thing using `ls`
with two paths as arguments --- like most Unix commands,
`ls` can be given multiple paths at once:

```bash
$ cp quotes.txt thesis/quotations.txt
$ ls quotes.txt thesis/quotations.txt
```

```output
quotes.txt   thesis/quotations.txt
```

We can also copy a directory and all its contents by using the
[recursive](https://en.wikipedia.org/wiki/Recursion) option `-r`,
e.g. to back up a directory:

```bash
$ cp -r thesis thesis_backup
```

We can check the result by listing the contents of both the `thesis` and `thesis_backup` directory:

```bash
$ ls thesis thesis_backup
```

```output
thesis:
quotations.txt

thesis_backup:
quotations.txt
```

It is important to include the `-r` flag. If you want to copy a directory and you omit this option
you will see a message that the directory has been omitted because `-r not specified`.

``` bash
$ cp thesis thesis_backup
```

```error
cp: -r not specified; omitting directory 'thesis'
```


### :muscle: Challenge

### Renaming Files

Suppose that you created a plain-text file in your current directory to contain a list of the
statistical tests you will need to do to analyze your data, and named it `statstics.txt`

After creating and saving this file you realize you misspelled the filename! You want to
correct the mistake, which of the following commands could you use to do so?

1. `cp statstics.txt statistics.txt`
2. `mv statstics.txt statistics.txt`
3. `mv statstics.txt .`
4. `cp statstics.txt .`

<details> <summary>View Solution...</summary>

### Solution

1. No.  While this would create a file with the correct name,
the incorrectly named file still exists in the directory
and would need to be deleted.
2. Yes, this would work to rename the file.
3. No, the period(.) indicates where to move the file, but does not provide a new file name;
identical file names
cannot be created.
4. No, the period(.) indicates where to copy the file, but does not provide a new file name;
identical file names cannot be created.

</details>



### :muscle: Challenge

### Moving and Copying

What is the output of the closing `ls` command in the sequence shown below?

```bash
$ pwd
```

```output
/Users/jamie/data
```

```bash
$ ls
```

```output
proteins.dat
```

```bash
$ mkdir recombined
$ mv proteins.dat recombined/
$ cp recombined/proteins.dat ../proteins-saved.dat
$ ls
```

1. `proteins-saved.dat recombined`
2. `recombined`
3. `proteins.dat recombined`
4. `proteins-saved.dat`

<details> <summary>View Solution...</summary>

### Solution

We start in the `/Users/jamie/data` directory, and create a new folder called `recombined`.
The second line moves (`mv`) the file `proteins.dat` to the new folder (`recombined`).
The third line makes a copy of the file we just moved.
The tricky part here is where the file was copied to.
Recall that `..` means 'go up a level', so the copied file is now in `/Users/jamie`.
Notice that `..` is interpreted with respect to the current working
directory, **not** with respect to the location of the file being copied.
So, the only thing that will show using ls (in `/Users/jamie/data`) is the recombined folder.

1. No, see explanation above.  `proteins-saved.dat` is located at `/Users/jamie`
2. Yes
3. No, see explanation above.  `proteins.dat` is located at `/Users/jamie/data/recombined`
4. No, see explanation above.  `proteins-saved.dat` is located at `/Users/jamie`

</details>



> [!NOTE]
>### Cut for time: `rm`
>
>- `rm` is used to remove files and folders.
>- Tip: `-i` works the same for `rm` as for `mv`


## Pipes and filters



Now that we know a few basic commands,
we can finally look at the shell's most powerful feature:
the ease with which it lets us combine existing programs in new ways.
We'll start with the directory `shell-lesson-data/exercise-data/alkanes`
that contains six files describing some simple organic molecules.
The `.pdb` extension indicates that these files are in Protein Data Bank format,
a simple text format that specifies the type and position of each atom in the molecule.

```bash
$ ls
```

```output
cubane.pdb    methane.pdb    pentane.pdb
ethane.pdb    octane.pdb     propane.pdb
```

Let's run an example command:

```bash
$ wc cubane.pdb
```

```output
20  156 1158 cubane.pdb
```

`wc` is the 'word count' command:
it counts the number of lines, words, and characters in files (returning the values
in that order from left to right).

If we run the command `wc *.pdb`, the `*` in `*.pdb` matches zero or more characters,
so the shell turns `*.pdb` into a list of all `.pdb` files in the current directory:

```bash
$ wc *.pdb
```

```output
20  156  1158  cubane.pdb
12  84   622   ethane.pdb
9  57   422   methane.pdb
30  246  1828  octane.pdb
21  165  1226  pentane.pdb
15  111  825   propane.pdb
107  819  6081  total
```

Note that `wc *.pdb` also shows the total number of all lines in the last line of the output.

If we run `wc -l` instead of just `wc`,
the output shows only the number of lines per file:

```bash
$ wc -l *.pdb
```

```output
20  cubane.pdb
12  ethane.pdb
9  methane.pdb
30  octane.pdb
21  pentane.pdb
15  propane.pdb
107  total
```

The `-m` and `-w` options can also be used with the `wc` command to show
only the number of characters or the number of words, respectively.

> [!NOTE]
>
>### Why Isn't It Doing Anything?
>
>What happens if a command is supposed to process a file, but we
>don't give it a filename? For example, what if we type:
>
>```bash
>$ wc -l
>```
>
>but don't type `*.pdb` (or anything else) after the command?
>Since it doesn't have any filenames, `wc` assumes it is supposed to
>process input given at the command prompt, so it just sits there and waits
>for us to give it some data interactively. From the outside, though, all we
>see is it sitting there, and the command doesn't appear to do anything.
>
>If you make this kind of mistake, you can escape out of this state by
>holding down the control key (<kbd>Ctrl</kbd>) and pressing the letter
><kbd>C</kbd> once: <kbd>Ctrl</kbd>\+<kbd>C</kbd>. Then release both keys.
>
>


### Capturing output from commands

Which of these files contains the fewest lines?
It's an easy question to answer when there are only six files,
but what if there were 6000?
Our first step toward a solution is to run the command:

```bash
$ wc -l *.pdb > lengths.txt
```

The greater than symbol, `>`, tells the shell to **redirect** the command's output to a
file instead of printing it to the screen. This command prints no screen output, because
everything that `wc` would have printed has gone into the file `lengths.txt` instead.
If the file doesn't exist prior to issuing the command, the shell will create the file.
If the file exists already, it will be silently overwritten, which may lead to data loss.
Thus, **redirect** commands require caution.

`ls lengths.txt` confirms that the file exists:

```bash
$ ls lengths.txt
```

```output
lengths.txt
```

We can now send the content of `lengths.txt` to the screen using `cat lengths.txt`.
The `cat` command gets its name from 'concatenate' i.e. join together,
and it prints the contents of files one after another.
There's only one file in this case,
so `cat` just shows us what it contains:

```bash
$ cat lengths.txt
```

```output
20  cubane.pdb
12  ethane.pdb
9  methane.pdb
30  octane.pdb
21  pentane.pdb
15  propane.pdb
107  total
```

> [!NOTE]
>
>### Output Page by Page
>
>We'll continue to use `cat` in this lesson, for convenience and consistency,
>but it has the disadvantage that it always dumps the whole file onto your screen.
>More useful in practice is the command `less` (e.g. `less lengths.txt`).
>This displays a screenful of the file, and then stops.
>You can go forward one screenful by pressing the spacebar,
>or back one by pressing `b`.  Press `q` to quit.
>
>


### Filtering output

Next we'll use the `sort` command to sort the contents of the `lengths.txt` file.
But first we'll do an exercise to learn a little about the sort command:

### :muscle: Challenge

### What Does `sort -n` Do?

The file `shell-lesson-data/exercise-data/numbers.txt` contains the following lines:

```source
10
2
19
22
6
```

If we run `sort` on this file, the output is:

```output
10
19
2
22
6
```

If we run `sort -n` on the same file, we get this instead:

```output
2
6
10
19
22
```

Explain why `-n` has this effect.

<details> <summary>View Solution...</summary>

### Solution

The `-n` option specifies a numerical rather than an alphanumerical sort.



</details>



We will also use the `-n` option to specify that the sort is
numerical instead of alphanumerical.
This does *not* change the file;
instead, it sends the sorted result to the screen:

```bash
$ sort -n lengths.txt
```

```output
9  methane.pdb
12  ethane.pdb
15  propane.pdb
20  cubane.pdb
21  pentane.pdb
30  octane.pdb
107  total
```

We can put the sorted list of lines in another temporary file called `sorted-lengths.txt`
by putting `> sorted-lengths.txt` after the command,
just as we used `> lengths.txt` to put the output of `wc` into `lengths.txt`.
Once we've done that,
we can run another command called `head` to get the first few lines in `sorted-lengths.txt`:

```bash
$ sort -n lengths.txt > sorted-lengths.txt
$ head -n 1 sorted-lengths.txt
```

```output
9  methane.pdb
```

Using `-n 1` with `head` tells it that
we only want the first line of the file;
`-n 20` would get the first 20,
and so on.
Since `sorted-lengths.txt` contains the lengths of our files ordered from least to greatest,
the output of `head` must be the file with the fewest lines.

> [!NOTE]
>
>### Redirecting to the same file
>
>It's a very bad idea to try redirecting
>the output of a command that operates on a file
>to the same file. For example:
>
>```bash
>$ sort -n lengths.txt > lengths.txt
>```
>
>Doing something like this may give you
>incorrect results and/or delete
>the contents of `lengths.txt`.
>
>


### :muscle: Challenge

### What Does `>>` Mean?

We have seen the use of `>`, but there is a similar operator `>>`
which works slightly differently.
We'll learn about the differences between these two operators by printing some strings.
We can use the `echo` command to print strings e.g.

```bash
$ echo The echo command prints text
```

```output
The echo command prints text
```

Now test the commands below to reveal the difference between the two operators:

```bash
$ echo hello > testfile01.txt
```

and:

```bash
$ echo hello >> testfile02.txt
```

Hint: Try executing each command twice in a row and then examining the output files.

<details> <summary>View Solution...</summary>

### Solution

In the first example with `>`, the string 'hello' is written to `testfile01.txt`,
but the file gets overwritten each time we run the command.

We see from the second example that the `>>` operator also writes 'hello' to a file
(in this case `testfile02.txt`),
but appends the string to the file if it already exists
(i.e. when we run it for the second time).



</details>



### :muscle: Challenge

### Appending Data

We have already met the `head` command, which prints lines from the start of a file.
`tail` is similar, but prints lines from the end of a file instead.

Consider the file `shell-lesson-data/exercise-data/animal-counts/animals.csv`.
After these commands, select the answer that
corresponds to the file `animals-subset.csv`:

```bash
$ head -n 3 animals.csv > animals-subset.csv
$ tail -n 2 animals.csv >> animals-subset.csv
```

1. The first three lines of `animals.csv`
2. The last two lines of `animals.csv`
3. The first three lines and the last two lines of `animals.csv`
4. The second and third lines of `animals.csv`

<details> <summary>View Solution...</summary>

### Solution

Option 3 is correct.
For option 1 to be correct we would only run the `head` command.
For option 2 to be correct we would only run the `tail` command.
For option 4 to be correct we would have to pipe the output of `head` into `tail -n 2`
by doing `head -n 3 animals.csv | tail -n 2 > animals-subset.csv`



</details>



### Passing output to another command

In our example of finding the file with the fewest lines,
we are using two intermediate files `lengths.txt` and `sorted-lengths.txt` to store output.
This is a confusing way to work because
even once you understand what `wc`, `sort`, and `head` do,
those intermediate files make it hard to follow what's going on.
We can make it easier to understand by running `sort` and `head` together:

```bash
$ sort -n lengths.txt | head -n 1
```

```output
9  methane.pdb
```

The vertical bar, `|`, between the two commands is called a **pipe**.
It tells the shell that we want to use
the output of the command on the left
as the input to the command on the right.

This has removed the need for the `sorted-lengths.txt` file.

### Combining multiple commands

Nothing prevents us from chaining pipes consecutively.
We can for example send the output of `wc` directly to `sort`,
and then send the resulting output to `head`.
This removes the need for any intermediate files.

We'll start by using a pipe to send the output of `wc` to `sort`:

```bash
$ wc -l *.pdb | sort -n
```

```output
9 methane.pdb
12 ethane.pdb
15 propane.pdb
20 cubane.pdb
21 pentane.pdb
30 octane.pdb
107 total
```

We can then send that output through another pipe, to `head`, so that the full pipeline becomes:

```bash
$ wc -l *.pdb | sort -n | head -n 1
```

```output
9  methane.pdb
```

This is exactly like a mathematician nesting functions like *log(3x)*
and saying 'the log of three times *x*'.
In our case,
the algorithm is 'head of sort of line count of `*.pdb`'.

The redirection and pipes used in the last few commands are illustrated below:

![](fig/redirects-and-pipes.svg){alt='Redirects and Pipes of different commands: "wc -l \*.pdb" will direct theoutput to the shell. "wc -l \*.pdb > lengths" will direct output to the file"lengths". "wc -l \*.pdb | sort -n | head -n 1" will build a pipeline where theoutput of the "wc" command is the input to the "sort" command, the output ofthe "sort" command is the input to the "head" command and the output of the"head" command is directed to the shell'}

### :muscle: Challenge

### Piping Commands Together

In our current directory, we want to find the 3 files which have the least number of
lines. Which command listed below would work?

1. `wc -l * > sort -n > head -n 3`
2. `wc -l * | sort -n | head -n 1-3`
3. `wc -l * | head -n 3 | sort -n`
4. `wc -l * | sort -n | head -n 3`

<details> <summary>View Solution...</summary>

### Solution

Option 4 is the solution.
The pipe character `|` is used to connect the output from one command to
the input of another.
`>` is used to redirect standard output to a file.
Try it in the `shell-lesson-data/exercise-data/alkanes` directory!



</details>



### Tools designed to work together

This idea of linking programs together is why Unix has been so successful.
Instead of creating enormous programs that try to do many different things,
Unix programmers focus on creating lots of simple tools that each do one job well,
and that work well with each other.
This programming model is called 'pipes and filters'.
We've already seen pipes;
a **filter** is a program like `wc` or `sort`
that transforms a stream of input into a stream of output.
Almost all of the standard Unix tools can work this way.
Unless told to do otherwise,
they read from standard input,
do something with what they've read,
and write to standard output.

The key is that any program that reads lines of text from standard input
and writes lines of text to standard output
can be combined with every other program that behaves this way as well.
You can *and should* write your programs this way
so that you and other people can put those programs into pipes to multiply their power.

### :muscle: Challenge

### Pipe Reading Comprehension

A file called `animals.csv` (in the `shell-lesson-data/exercise-data/animal-counts` folder)
contains the following data:

```source
2012-11-05,deer,5
2012-11-05,rabbit,22
2012-11-05,raccoon,7
2012-11-06,rabbit,19
2012-11-06,deer,2
2012-11-06,fox,4
2012-11-07,rabbit,16
2012-11-07,bear,1
```

What text passes through each of the pipes and the final redirect in the pipeline below?
Note, the `sort -r` command sorts in reverse order.

```bash
$ cat animals.csv | head -n 5 | tail -n 3 | sort -r > final.txt
```

Hint: build the pipeline up one command at a time to test your understanding

<details> <summary>View Solution...</summary>

### Solution

The `head` command extracts the first 5 lines from `animals.csv`.
Then, the last 3 lines are extracted from the previous 5 by using the `tail` command.
With the `sort -r` command those 3 lines are sorted in reverse order.
Finally, the output is redirected to a file: `final.txt`.
The content of this file can be checked by executing `cat final.txt`.
The file should contain the following lines:

```source
2012-11-06,rabbit,19
2012-11-06,deer,2
2012-11-05,raccoon,7
```

</details>



### :muscle: Challenge

### Pipe Construction

For the file `animals.csv` from the previous exercise, consider the following command:

```bash
$ cut -d , -f 2 animals.csv
```

The `cut` command is used to select or 'cut out' certain sections of each line in the file for
further processing while leaving the original file unchanged.
By default, `cut` expects the lines to be separated into columns by a <kbd>Tab</kbd> character.
A character used in this way is called a **delimiter**.
In the example above we use the `-d` option to specify the comma as our delimiter character
instead of <kbd>Tab</kbd>.
We have also used the `-f` option to specify that we want to extract the second field (column).
This gives the following output:

```output
deer
rabbit
raccoon
rabbit
deer
fox
rabbit
bear
```

The `uniq` command filters out adjacent matching lines in a file.
How could you extend this pipeline (using `uniq` and another command) to find
out what animals the file contains (without any duplicates in their
names)?

<details> <summary>View Solution...</summary>

### Solution

```bash
$ cut -d , -f 2 animals.csv | sort | uniq
```

</details>



### :muscle: Challenge

### Which Pipe?

The file `animals.csv` contains 8 lines of data formatted as follows:

```output
2012-11-05,deer,5
2012-11-05,rabbit,22
2012-11-05,raccoon,7
2012-11-06,rabbit,19
...
```

The `uniq` command has a `-c` option which gives a count of the
number of times a line occurs in its input.  Assuming your current
directory is `shell-lesson-data/exercise-data/animal-counts`,
what command would you use to produce a table that shows
the total count of each type of animal in the file?

1. `sort animals.csv | uniq -c`
2. `sort -t, -k2,2 animals.csv | uniq -c`
3. `cut -d, -f 2 animals.csv | uniq -c`
4. `cut -d, -f 2 animals.csv | sort | uniq -c`
5. `cut -d, -f 2 animals.csv | sort | uniq -c | wc -l`

<details> <summary>View Solution...</summary>

### Solution

Option 4 is the correct answer.
If you have difficulty understanding why, try running the commands, or sub-sections of
the pipelines (make sure you are in the `shell-lesson-data/exercise-data/animal-counts`
directory).



</details>



### Nelle's Pipeline: Checking Files

Nelle has run her samples through the assay machines
and created 17 files in the `north-pacific-gyre` directory described earlier.
As a quick check, starting from the `shell-lesson-data` directory, Nelle types:

```bash
$ cd north-pacific-gyre
$ wc -l *.txt
```

The output is 18 lines that look like this:

```output
300 NENE01729A.txt
300 NENE01729B.txt
300 NENE01736A.txt
300 NENE01751A.txt
300 NENE01751B.txt
300 NENE01812A.txt
... ...
```

Now she types this:

```bash
$ wc -l *.txt | sort -n | head -n 5
```

```output
240 NENE02018B.txt
300 NENE01729A.txt
300 NENE01729B.txt
300 NENE01736A.txt
300 NENE01751A.txt
```

Whoops: one of the files is 60 lines shorter than the others.
When she goes back and checks it,
she sees that she did that assay at 8:00 on a Monday morning --- someone
was probably in using the machine on the weekend,
and she forgot to reset it.
Before re-running that sample,
she checks to see if any files have too much data:

```bash
$ wc -l *.txt | sort -n | tail -n 5
```

```output
300 NENE02040B.txt
300 NENE02040Z.txt
300 NENE02043A.txt
300 NENE02043B.txt
5040 total
```

Those numbers look good --- but what's that 'Z' doing there in the third-to-last line?
All of her samples should be marked 'A' or 'B';
by convention,
her lab uses 'Z' to indicate samples with missing information.
To find others like it, she does this:

```bash
$ ls *Z.txt
```

```output
NENE01971Z.txt    NENE02040Z.txt
```

Sure enough,
when she checks the log on her laptop,
there's no depth recorded for either of those samples.
Since it's too late to get the information any other way,
she must exclude those two files from her analysis.
She could delete them using `rm`,
but there are actually some analyses she might do later where depth doesn't matter,
so instead, she'll have to be careful later on to select files using the wildcard expressions
`NENE*A.txt NENE*B.txt`.

### :muscle: Challenge

### Removing Unneeded Files

Suppose you want to delete your processed data files, and only keep
your raw files and processing script to save storage.
The raw files end in `.dat` and the processed files end in `.txt`.
Which of the following would remove all the processed data files,
and *only* the processed data files?

1. `rm ?.txt`
2. `rm *.txt`
3. `rm * .txt`
4. `rm *.*`

<details> <summary>View Solution...</summary>

### Solution

1. This would remove `.txt` files with one-character names
2. This is the correct answer
3. The shell would expand `*` to match everything in the current directory,
so the command would try to remove all matched files and an additional
file called `.txt`
4. The shell expands `*.*` to match all filenames containing at least one
`.`, including the processed files (`.txt`) *and* raw files (`.dat`)



</details>





### Summary

- `wc` counts lines, words, and characters in its inputs.
- `cat` displays the contents of its inputs.
- `sort` sorts its inputs.
- `head` displays the first 10 lines of its input by default without additional arguments.
- `tail` displays the last 10 lines of its input by default without additional arguments.
- `command > [file]` redirects a command's output to a file (overwriting any existing content).
- `command >> [file]` appends a command's output to a file.
- `[first] | [second]` is a pipeline: the output of the first command is used as the input to the second.
- The best way to use the shell is to use pipes to combine simple single-purpose programs (filters).





## Shell Scripts

Now, we are going to take the commands we repeat frequently and save them in files
so that we can re-run all those operations again later by typing a single command.
A bunch of commands saved in a file is usually called a **shell script**,
these are small programs.

Not only will writing shell scripts make your work faster, but also you won't have to retype
the same commands over and over again. It will also make it more accurate (fewer chances for
typos) and more reproducible. If you come back to your work later (or if someone else finds
your work and wants to build on it), you will be able to reproduce the same results simply
by running your script, rather than having to remember or retype a long list of commands.

Let's start by going back to `alkanes/` and creating a new file, `middle.sh` which will
become our shell script:

```bash
$ cd alkanes
$ nano middle.sh
```

The command `nano middle.sh` opens the file `middle.sh` within the text editor 'nano'
(which runs within the shell).
If the file does not exist, it will be created.
We can use the text editor to directly edit the file by inserting the following line:

```source
head -n 15 octane.pdb | tail -n 5
```

This is a variation on the pipe we constructed earlier, which selects lines 11-15 of
the file `octane.pdb`. Remember, we are *not* running it as a command just yet;
we are only incorporating the commands in a file.

Then we save the file (`Ctrl-O` in nano) and exit the text editor (`Ctrl-X` in nano).
Check that the directory `alkanes` now contains a file called `middle.sh`.

Once we have saved the file,
we can ask the shell to execute the commands it contains.
Our shell is called `bash`, so we run the following command:

```bash
$ bash middle.sh
```

```output
ATOM      9  H           1      -4.502   0.681   0.785  1.00  0.00
ATOM     10  H           1      -5.254  -0.243  -0.537  1.00  0.00
ATOM     11  H           1      -4.357   1.252  -0.895  1.00  0.00
ATOM     12  H           1      -3.009  -0.741  -1.467  1.00  0.00
ATOM     13  H           1      -3.172  -1.337   0.206  1.00  0.00
```

Sure enough,
our script's output is exactly what we would get if we ran that pipeline directly.

> [!NOTE]
>
>### Text vs. Whatever
>
>We usually call programs like Microsoft Word or LibreOffice Writer "text
>editors", but we need to be a bit more careful when it comes to
>programming. By default, Microsoft Word uses `.docx` files to store not
>only text, but also formatting information about fonts, headings, and so
>on. This extra information isn't stored as characters and doesn't mean
>anything to tools like `head`, which expects input files to contain
>nothing but the letters, digits, and punctuation on a standard computer
>keyboard. When editing programs, therefore, you must either use a plain
>text editor or be careful to save files as plain text.
>
>


What if we want to select lines from an arbitrary file?
We could edit `middle.sh` each time to change the filename,
but that would probably take longer than typing the command out again
in the shell and executing it with a new file name.
Instead, let's edit `middle.sh` and make it more versatile:

```bash
$ nano middle.sh
```

Now, within "nano", replace the text `octane.pdb` with the special variable called `$1`:

```source
head -n 15 "$1" | tail -n 5
```

Inside a shell script,
`$1` means 'the first filename (or other argument) on the command line'.
We can now run our script like this:

```bash
$ bash middle.sh octane.pdb
```

```output
ATOM      9  H           1      -4.502   0.681   0.785  1.00  0.00
ATOM     10  H           1      -5.254  -0.243  -0.537  1.00  0.00
ATOM     11  H           1      -4.357   1.252  -0.895  1.00  0.00
ATOM     12  H           1      -3.009  -0.741  -1.467  1.00  0.00
ATOM     13  H           1      -3.172  -1.337   0.206  1.00  0.00
```

or on a different file like this:

```bash
$ bash middle.sh pentane.pdb
```

```output
ATOM      9  H           1       1.324   0.350  -1.332  1.00  0.00
ATOM     10  H           1       1.271   1.378   0.122  1.00  0.00
ATOM     11  H           1      -0.074  -0.384   1.288  1.00  0.00
ATOM     12  H           1      -0.048  -1.362  -0.205  1.00  0.00
ATOM     13  H           1      -1.183   0.500  -1.412  1.00  0.00
```

> [!NOTE]
>
>### Double-Quotes Around Arguments
>
>For the same reason that we put the loop variable inside double-quotes,
>in case the filename happens to contain any spaces,
>we surround `$1` with double-quotes.
>
>


Currently, we need to edit `middle.sh` each time we want to adjust the range of
lines that is returned.
Let's fix that by configuring our script to instead use three command-line arguments.
After the first command-line argument (`$1`), each additional argument that we
provide will be accessible via the special variables `$1`, `$2`, `$3`,
which refer to the first, second, third command-line arguments, respectively.

Knowing this, we can use additional arguments to define the range of lines to
be passed to `head` and `tail` respectively:

```bash
$ nano middle.sh
```

```source
head -n "$2" "$1" | tail -n "$3"
```

We can now run:

```bash
$ bash middle.sh pentane.pdb 15 5
```

```output
ATOM      9  H           1       1.324   0.350  -1.332  1.00  0.00
ATOM     10  H           1       1.271   1.378   0.122  1.00  0.00
ATOM     11  H           1      -0.074  -0.384   1.288  1.00  0.00
ATOM     12  H           1      -0.048  -1.362  -0.205  1.00  0.00
ATOM     13  H           1      -1.183   0.500  -1.412  1.00  0.00
```

By changing the arguments to our command, we can change our script's
behaviour:

```bash
$ bash middle.sh pentane.pdb 20 5
```

```output
ATOM     14  H           1      -1.259   1.420   0.112  1.00  0.00
ATOM     15  H           1      -2.608  -0.407   1.130  1.00  0.00
ATOM     16  H           1      -2.540  -1.303  -0.404  1.00  0.00
ATOM     17  H           1      -3.393   0.254  -0.321  1.00  0.00
TER      18              1
```

This works,
but it may take the next person who reads `middle.sh` a moment to figure out what it does.
We can improve our script by adding some **comments** at the top:

```bash
$ nano middle.sh
```

```source
## Select lines from the middle of a file.
## Usage: bash middle.sh filename end_line num_lines
head -n "$2" "$1" | tail -n "$3"
```

A comment starts with a `#` character and runs to the end of the line.
The computer ignores comments,
but they're invaluable for helping people (including your future self) understand and use scripts.
The only caveat is that each time you modify the script,
you should check that the comment is still accurate. An explanation that sends
the reader in the wrong direction is worse than none at all.

What if we want to process many files in a single pipeline?
For example, if we want to sort our `.pdb` files by length, we would type:

```bash
$ wc -l *.pdb | sort -n
```

because `wc -l` lists the number of lines in the files
(recall that `wc` stands for 'word count', adding the `-l` option means 'count lines' instead)
and `sort -n` sorts things numerically.
We could put this in a file,
but then it would only ever sort a list of `.pdb` files in the current directory.
If we want to be able to get a sorted list of other kinds of files,
we need a way to get all those names into the script.
We can't use `$1`, `$2`, and so on
because we don't know how many files there are.
Instead, we use the special variable `$@`,
which means,
'All of the command-line arguments to the shell script'.
We also should put `$@` inside double-quotes
to handle the case of arguments containing spaces
(`"$@"` is special syntax and is equivalent to `"$1"` `"$2"` ...).

Here's an example:

```bash
$ nano sorted.sh
```

```source
## Sort files by their length.
## Usage: bash sorted.sh one_or_more_filenames
wc -l "$@" | sort -n
```

```bash
$ bash sorted.sh *.pdb ../creatures/*.dat
```

```output
9 methane.pdb
12 ethane.pdb
15 propane.pdb
20 cubane.pdb
21 pentane.pdb
30 octane.pdb
163 ../creatures/basilisk.dat
163 ../creatures/minotaur.dat
163 ../creatures/unicorn.dat
596 total
```

### :muscle: Challenge

### List Unique Species

Leah has several hundred data files, each of which is formatted like this:

```source
2013-11-05,deer,5
2013-11-05,rabbit,22
2013-11-05,raccoon,7
2013-11-06,rabbit,19
2013-11-06,deer,2
2013-11-06,fox,1
2013-11-07,rabbit,18
2013-11-07,bear,1
```

An example of this type of file is given in
`shell-lesson-data/exercise-data/animal-counts/animals.csv`.

We can use the command `cut -d , -f 2 animals.csv | sort | uniq` to produce
the unique species in `animals.csv`.
In order to avoid having to type out this series of commands every time,
a scientist may choose to write a shell script instead.

Write a shell script called `species.sh` that takes a
filename as a command-line argument and uses a variation of the above command
to print a list of the unique species appearing in that file.

<details> <summary>View Solution...</summary>

### Solution

```bash
## Script to find unique species in csv files where species is the second data field

echo "Unique species in $file:"
# Extract species names
cut -d , -f 2 "$1" | sort | uniq

```

</details>



Suppose we have just run a series of commands that did something useful --- for example,
creating a graph we'd like to use in a paper.
We'd like to be able to re-create the graph later if we need to,
so we want to save the commands in a file.
Instead of typing them in again
(and potentially getting them wrong)
we can do this:

```bash
$ history | tail -n 5 > redo-figure-3.sh
```

The file `redo-figure-3.sh` now contains:

```source
297 bash goostats.sh NENE01729B.txt stats-NENE01729B.txt
298 bash goodiff.sh stats-NENE01729B.txt /data/validated/01729.txt > 01729-differences.txt
299 cut -d ',' -f 2-3 01729-differences.txt > 01729-time-series.txt
300 ygraph --format scatter --color bw --borders none 01729-time-series.txt figure-3.png
301 history | tail -n 5 > redo-figure-3.sh
```

After a moment's work in an editor to remove the serial numbers on the commands,
and to remove the final line where we called the `history` command,
we have a completely accurate record of how we created that figure.

### :muscle: Challenge

### Why Record Commands in the History Before Running Them?

If you run the command:

```bash
$ history | tail -n 5 > recent.sh
```

the last command in the file is the `history` command itself, i.e.,
the shell has added `history` to the command log before actually
running it. In fact, the shell *always* adds commands to the log
before running them. Why do you think it does this?

<details> <summary>View Solution...</summary>

### Solution

If a command causes something to crash or hang, it might be useful
to know what that command was, in order to investigate the problem.
Were the command only be recorded after running it, we would not
have a record of the last command run in the event of a crash.



</details>



In practice, most people develop shell scripts by running commands
at the shell prompt a few times
to make sure they're doing the right thing,
then saving them in a file for re-use.
This style of work allows people to recycle
what they discover about their data and their workflow with one call to `history`
and a bit of editing to clean up the output
and save it as a shell script.

### Nelle's Pipeline: Creating a Script

Nelle's supervisor insisted that all her analytics must be reproducible.
The easiest way to capture all the steps is in a script.

First we return to Nelle's project directory:

```bash
$ cd ../../north-pacific-gyre/
```

She creates a file using `nano` ...

```bash
$ nano do-stats.sh
```

...which contains the following:

```bash
## Calculate stats for data files.
for datafile in "$@"
do
echo $datafile
bash goostats.sh $datafile stats-$datafile
done
```

She saves this in a file called `do-stats.sh`
so that she can now re-do the first stage of her analysis by typing:

```bash
$ bash do-stats.sh NENE*A.txt NENE*B.txt
```

She can also do this:

```bash
$ bash do-stats.sh NENE*A.txt NENE*B.txt | wc -l
```

so that the output is just the number of files processed
rather than the names of the files that were processed.

One thing to note about Nelle's script is that
it lets the person running it decide what files to process.
She could have written it as:

```bash
## Calculate stats for Site A and Site B data files.
for datafile in NENE*A.txt NENE*B.txt
do
echo $datafile
bash goostats.sh $datafile stats-$datafile
done
```

The advantage is that this always selects the right files:
she doesn't have to remember to exclude the 'Z' files.
The disadvantage is that it *always* selects just those files --- she can't run it on all files
(including the 'Z' files),
or on the 'G' or 'H' files her colleagues in Antarctica are producing,
without editing the script.
If she wanted to be more adventurous,
she could modify her script to check for command-line arguments,
and use `NENE*A.txt NENE*B.txt` if none were provided.
Of course, this introduces another tradeoff between flexibility and complexity.

### :muscle: Challenge

### Variables in Shell Scripts

In the `alkanes` directory, imagine you have a shell script called `script.sh` containing the
following commands:

```bash
head -n $2 $1
tail -n $3 $1
```

While you are in the `alkanes` directory, you type the following command:

```bash
$ bash script.sh '*.pdb' 1 1
```

Which of the following outputs would you expect to see?

1. All of the lines between the first and the last lines of each file ending in `.pdb`
in the `alkanes` directory
2. The first and the last line of each file ending in `.pdb` in the `alkanes` directory
3. The first and the last line of each file in the `alkanes` directory
4. An error because of the quotes around `*.pdb`

<details> <summary>View Solution...</summary>

### Solution

The correct answer is 2.

The special variables `$1`, `$2` and `$3` represent the command line arguments given to the
script, such that the commands run are:

```bash
$ head -n 1 cubane.pdb ethane.pdb octane.pdb pentane.pdb propane.pdb
$ tail -n 1 cubane.pdb ethane.pdb octane.pdb pentane.pdb propane.pdb
```

The shell does not expand `'*.pdb'` because it is enclosed by quote marks.
As such, the first argument to the script is `'*.pdb'` which gets expanded within the
script by `head` and `tail`.



</details>



### :muscle: Challenge

### Find the Longest File With a Given Extension

Write a shell script called `longest.sh` that takes the name of a
directory and a filename extension as its arguments, and prints
out the name of the file with the most lines in that directory
with that extension. For example:

```bash
$ bash longest.sh shell-lesson-data/exercise-data/alkanes pdb
```

would print the name of the `.pdb` file in `shell-lesson-data/exercise-data/alkanes` that has
the most lines.

Feel free to test your script on another directory e.g.

```bash
$ bash longest.sh shell-lesson-data/exercise-data/writing txt
```

<details> <summary>View Solution...</summary>

### Solution

```bash
## Shell script which takes two arguments:
##    1. a directory name
##    2. a file extension
## and prints the name of the file in that directory
## with the most lines which matches the file extension.

wc -l $1/*.$2 | sort -n | tail -n 2 | head -n 1
```

The first part of the pipeline, `wc -l $1/*.$2 | sort -n`, counts
the lines in each file and sorts them numerically (largest last). When
there's more than one file, `wc` also outputs a final summary line,
giving the total number of lines across *all* files.  We use `tail -n 2 | head -n 1` to throw away this last line.

With `wc -l $1/*.$2 | sort -n | tail -n 1` we'll see the final summary
line: we can build our pipeline up in pieces to be sure we understand
the output.

</details>



### :muscle: Challenge

### Script Reading Comprehension

For this question, consider the `shell-lesson-data/exercise-data/alkanes` directory once again.
This contains a number of `.pdb` files in addition to any other files you
may have created.
Explain what each of the following three scripts would do when run as
`bash script1.sh *.pdb`, `bash script2.sh *.pdb`, and `bash script3.sh *.pdb` respectively.

```bash
## Script 1
echo *.*
```

```bash
## Script 2
for filename in $1 $2 $3
do
cat $filename
done
```

```bash
## Script 3
echo $@.pdb
```

<details> <summary>View Solution...</summary>

### Solutions

In each case, the shell expands the wildcard in `*.pdb` before passing the resulting
list of file names as arguments to the script.

Script 1 would print out a list of all files containing a dot in their name.
The arguments passed to the script are not actually used anywhere in the script.

Script 2 would print the contents of the first 3 files with a `.pdb` file extension.
`$1`, `$2`, and `$3` refer to the first, second, and third argument respectively.

Script 3 would print all the arguments to the script (i.e. all the `.pdb` files),
followed by `.pdb`.
`$@` refers to *all* the arguments given to a shell script.

```output
cubane.pdb ethane.pdb methane.pdb octane.pdb pentane.pdb propane.pdb.pdb
```

</details>



### :muscle: Challenge

### Debugging Scripts

Suppose you have saved the following script in a file called `do-errors.sh`
in Nelle's `north-pacific-gyre` directory:

```bash
## Calculate stats for data files.
for datafile in "$@"
do
echo $datfile
bash goostats.sh $datafile stats-$datafile
done
```

When you run it from the `north-pacific-gyre` directory:

```bash
$ bash do-errors.sh NENE*A.txt NENE*B.txt
```

the output is blank.
To figure out why, re-run the script using the `-x` option:

```bash
$ bash -x do-errors.sh NENE*A.txt NENE*B.txt
```

What is the output showing you?
Which line is responsible for the error?

<details> <summary>View Solution...</summary>

### Solution

The `-x` option causes `bash` to run in debug mode.
This prints out each command as it is run, which will help you to locate errors.
In this example, we can see that `echo` isn't printing anything. We have made a typo
in the loop variable name, and the variable `datfile` doesn't exist, hence returning
an empty string.



</details>





### Summary

- Save commands in files (usually called shell scripts) for re-use.
- `bash [filename]` runs the commands saved in a file.
- `$@` refers to all of a shell script's command-line arguments.
- `$1`, `$2`, etc., refer to the first command-line argument, the second command-line argument, etc.
- Place variables in quotes if the values might have spaces in them.
- Letting users decide what files to process is more flexible and more consistent with built-in Unix commands.




