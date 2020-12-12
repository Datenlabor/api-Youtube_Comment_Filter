from snownlp import SnowNLP
from textblob import TextBlob
import sys
import re
import datetime
from googletrans import Translator

TAG_RE = re.compile(r'<[^>]+>')
def remove_tags(text):
    return TAG_RE.sub('', text)

def polarity_chinese(text):
    text = SnowNLP(text)
    return text.sentiments

def polarity_en(text):
    blob = TextBlob(text)
    return (blob.sentiment[0] + 1)/2


if __name__ == "__main__":
    analy_List = []
    #Get comment text filename
    filename = sys.argv[1]
    
    #Define output filename
    t = datetime.datetime.now().time()
    outfile = 'app/domain/videos/mappers/temp/' + t.strftime('%H_%M_%S_%f') + '_rtn.txt'
    #Read file and polarity analyze
    f = open(filename)
    line = f.readline()
    # Using googletrans package
    translator = Translator()
    while line:
        cleantext = remove_tags(line)

        language = translator.detect(line).lang
 
        if language == 'zh-CN' or language == 'zh-TW':
            try:
                result = polarity_chinese(cleantext)
            except:
                result = 0.5
        else:
            try:
                result = polarity_en(cleantext)
            except:
                result = 0.5

        analy_List.append(result)

        line = f.readline()

    f.close()
    
    f = open(outfile,"w")
    f.writelines([str(score) + '\n' for score in analy_List])
    f.close()

    print(outfile)

