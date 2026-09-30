class fasta_sequence:
    def __init__(self, header, sequence):
        self.header = header
        self.sequence = sequence

    def calculate_gc_content(self):
        gc_letters = self.sequence.count("G") + self.sequence.count("C")
        gc_content = (gc_letters / len(self.sequence))
        return gc_content

class fasta_file:
    def __init__(self, filename):
        self.filename = filename
        self.sequences = []

    def read_fasta(self):
        with open(self.filename, 'rt') as f:
            header = ""
            sequence = ""
            for line in f:
                if line.startswith(">"):
                    if header and sequence:
                        self.sequences.append(fasta_sequence(header, sequence))
                    header = line.strip()
                    sequence = ""
                else:
                    sequence += line.strip()
            if header and sequence:
                self.sequences.append(fasta_sequence(header, sequence))

    def calculate_gc_content(self, filename_output):
        handler = open(filename_output, "w")
        for sequence in self.sequences:
            handler.write(sequence.header + "\t" + str(sequence.calculate_gc_content()) + "\n")
        handler.close()


import sys

sequence_file = fasta_file(sys.argv[1])
sequence_file.read_fasta()
sequence_file.calculate_gc_content(sys.argv[2])
