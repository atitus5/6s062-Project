from subprocess import call

for i in xrange(1, 37):
    call(['dot', '-Tpdf', 'log%d.dot' % i, '-o', 'log%d.pdf' % i])
