import sys

IN_FILE = sys.argv[1]

def open_div(label):
    return {
        "instructor": "",
        "spoiler": "<details> <summary>More..</summary>",
        "challenge": "### :muscle: Challenge",
        "solution": "<details> <summary>View Solution...</summary>",
        "callout": "> [!NOTE]",
        "keypoints": "### Summary"
    }[label]

def close_div(label):
    if label in ('solution', 'spoiler'):
        return "</details>"
    return ""

quote_labels = ('callout',)

div_stack = []
look_for_title = False
label = ''
quote_depth = 0
for line in open(IN_FILE):
    line = line.strip()
    if line.startswith(':'):
        label = line.replace(':', '').replace(' ','')
        if len(label) == 0:
            label, length = div_stack.pop()
            # if len(line) != length: ValueError("Mismatch div")
            print(close_div(label))
            if label in quote_labels:
                quote_depth -=1
        else:
            print(open_div(label))
            div_stack.append((label, len(line)))
            if label in quote_labels:
                quote_depth +=1
    else:
        print(">" * len([label for (label, length) in div_stack if label in quote_labels]) + line)



