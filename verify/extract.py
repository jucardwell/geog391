import re,sys
src=open(sys.argv[1]).read()
chunks=re.findall(r'^```\{r([^}]*)\}\n(.*?)^```\s*$',src,flags=re.M|re.S)
out=[]
for i,(hdr,body) in enumerate(chunks):
    out.append(f'cat("\\n=== chunk {i+1}:{re.sub(r"[^A-Za-z0-9_= ,.-]","",hdr)[:40]}\\n")\n'+body)
open(sys.argv[2],'w').write('\n'.join(out))
