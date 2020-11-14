from snownlp import SnowNLP
import sys
import re

def polarity():
    text = SnowNLP(sys.argv[1])
    return text.sentiments


if __name__ == "__main__":
   polarity()

