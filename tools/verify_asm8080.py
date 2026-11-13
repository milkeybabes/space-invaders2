# asm8080.py - tiny two-pass 8080 assembler used to verify invadpt2.asm against the ROMs
# Minimal two-pass 8080 assembler for the generated source (ASMX-like subset)
import re,sys
# Intel 8080 mnemonic table: opcode -> (mnemonic, operand template); {w} 16-bit, {b} 8-bit
R=['B','C','D','E','H','L','M','A']
RP=['B','D','H','SP']; RPP=['B','D','H','PSW']
CC=['NZ','Z','NC','C','PO','PE','P','M']
T={}
T[0x00]=('NOP','')
for i,rp in enumerate(RP):
    T[0x01+16*i]=('LXI',rp+',{w}'); T[0x03+16*i]=('INX',rp); T[0x0B+16*i]=('DCX',rp); T[0x09+16*i]=('DAD',rp)
T[0x02]=('STAX','B'); T[0x12]=('STAX','D'); T[0x0A]=('LDAX','B'); T[0x1A]=('LDAX','D')
T[0x22]=('SHLD','{w}'); T[0x2A]=('LHLD','{w}'); T[0x32]=('STA','{w}'); T[0x3A]=('LDA','{w}')
for i,r in enumerate(R):
    T[0x04+8*i]=('INR',r); T[0x05+8*i]=('DCR',r); T[0x06+8*i]=('MVI',r+',{b}')
for i,mn in enumerate(['RLC','RRC','RAL','RAR','DAA','CMA','STC','CMC']): T[0x07+8*i]=(mn,'')
for d in range(8):
    for s_ in range(8): T[0x40+8*d+s_]=('MOV',R[d]+','+R[s_])
T[0x76]=('HLT','')
for i,(m1,m2) in enumerate([('ADD','ADI'),('ADC','ACI'),('SUB','SUI'),('SBB','SBI'),('ANA','ANI'),('XRA','XRI'),('ORA','ORI'),('CMP','CPI')]):
    for s_ in range(8): T[0x80+8*i+s_]=(m1,R[s_])
    T[0xC6+8*i]=(m2,'{b}')
for i,c in enumerate(CC):
    T[0xC0+8*i]=('R'+c,''); T[0xC2+8*i]=('J'+c,'{w}'); T[0xC4+8*i]=('C'+c,'{w}')
    T[0xC7+8*i]=('RST',str(i))
for i,rp in enumerate(RPP):
    T[0xC1+16*i]=('POP',rp); T[0xC5+16*i]=('PUSH',rp)
T[0xC3]=('JMP','{w}'); T[0xC9]=('RET',''); T[0xCD]=('CALL','{w}')
T[0xD3]=('OUT','{b}'); T[0xDB]=('IN','{b}')
T[0xE3]=('XTHL',''); T[0xE9]=('PCHL',''); T[0xEB]=('XCHG',''); T[0xF9]=('SPHL','')
T[0xF3]=('DI',''); T[0xFB]=('EI','')
REV={}
for op,(mn,tpl) in T.items():
    key=(mn,tpl.replace('{w}','#').replace('{b}','#'))
    REV[key]=op

def parse_num(t,sym):
    t=t.strip()
    m=re.match(r'^([A-Za-z_][A-Za-z0-9_]*)\s*([+-]\s*.+)?$',t)
    if m and m.group(1).upper() not in ('B','C','D','E','H','L','M','A','SP','PSW'):
        v=sym.get(m.group(1))
        if v is None: raise KeyError(m.group(1))
        if m.group(2): v+=parse_num(m.group(2).replace(' ','').lstrip('+'),sym) if m.group(2).strip()[0]=='+' else -parse_num(m.group(2).strip()[1:],sym)
        return v
    if t.lower().startswith('0x'): return int(t,16)
    if t.upper().endswith('H'): return int(t[:-1],16)
    return int(t)
def assemble(src):
    lines=src.split('\n')
    for pas in (1,2):
        sym=globals().get('_sym',{}) if pas==2 else {}
        mem={}; pc=0
        for no,ln in enumerate(lines,1):
            s=ln.split(';',1)[0].rstrip()
            if not s.strip(): continue
            m=re.match(r'^([A-Za-z_][A-Za-z0-9_]*)\s+EQU\s+(.+)$',s.strip())
            if m: sym[m.group(1)]=parse_num(m.group(2),sym); continue
            m=re.match(r'^([A-Za-z_][A-Za-z0-9_]*):\s*(.*)$',s.strip())
            if m:
                if pas==1:
                    if m.group(1) in sym: raise Exception('dup label %s line %d'%(m.group(1),no))
                    sym[m.group(1)]=pc
                s=m.group(2)
                if not s.strip(): continue
            parts=s.strip().split(None,1)
            mn=parts[0].upper(); ops=parts[1].strip() if len(parts)>1 else ''
            if mn=='CPU': continue
            if mn=='END': break
            if mn=='ORG': pc=parse_num(ops,sym); continue
            if mn=='DB':
                for t in ops.split(','):
                    mem[pc]=parse_num(t,sym)&0xFF if pas==2 else 0; pc+=1
                continue
            # instruction
            opl=[x.strip() for x in ops.split(',')] if ops else []
            # try register-form exact match first
            key=(mn,','.join(opl))
            if key in REV:
                mem[pc]=REV[key]; pc+=1; continue
            # find template with immediate in last position
            tpl=','.join(opl[:-1]+['#']) if opl else ''
            key=(mn,tpl)
            if key not in REV: raise Exception('line %d: cannot assemble %r'%(no,s))
            op=REV[key]; mem[pc]=op
            imm=opl[-1]
            n=3 if '{w}' in T[op][1] else 2
            if pas==2:
                v=parse_num(imm,sym)
                if n==2: mem[pc+1]=v&0xFF
                else: mem[pc+1]=v&0xFF; mem[pc+2]=(v>>8)&0xFF
            else:
                for k in range(1,n): mem[pc+k]=0
            pc+=n
        globals()['_sym']=sym
    return mem,sym
if __name__=='__main__':
    mem,sym=assemble(open(sys.argv[1]).read())
    lo=bytes(mem.get(a,0) for a in range(0,0x2000)); hi=bytes(mem.get(a,0) for a in range(0x4000,0x4800))
    import os
    d=sys.argv[2] if len(sys.argv)>2 else '.'
    r_lo=b''.join(open(os.path.join(d,n),'rb').read() for n in ['pv01','pv02','pv03','pv04']); r_hi=open(os.path.join(d,'pv05'),'rb').read()
    cov=len([a for a in mem if a<0x2000 or 0x4000<=a<0x4800])
    print('bytes assembled',cov,'of',0x2000+0x800)
    d1=[a for a in range(0x2000) if lo[a]!=r_lo[a]]; d2=[a for a in range(0x800) if hi[a]!=r_hi[a]]
    print('mismatches lo',len(d1),'hi',len(d2), ['%04X'%x for x in d1[:10]], ['%04X'%(0x4000+x) for x in d2[:10]])
    print('usage: python3 asm8080.py invadpt2.asm <folder with pv01..pv05>')
