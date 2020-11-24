from snownlp import SnowNLP
import sys
import re
import datetime


TAG_RE = re.compile(r'<[^>]+>')
def remove_tags(text):
    return TAG_RE.sub('', text)

def polarity(text):
    text = SnowNLP(text)
    return text.sentiments


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
    while line:
        cleantext = remove_tags(line)
        analy_List.append(polarity(cleantext))
        line = f.readline()
    f.close()
    
    f = open(outfile,"w")
    f.writelines([str(score) + '\n' for score in analy_List])
    f.close()

    print(outfile)

