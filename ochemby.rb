class Test
    attr_accessor :methanol, :cyclohexane
    
    def initialize
        @methanol = nil
    end
    
    def assemble_methanol
        @methanol = Molecule.new
        
        c1 = Atom.new("C")
        h1 = Atom.new("H")
        h2 = Atom.new("H")
        h3 = Atom.new("H")
        
        o1 = Atom.new("O")
        h4 = Atom.new("H")
        
        c1.bond_to(h1)
        c1.bond_to(h2)
        c1.bond_to(h3)
        c1.bond_to(o1)
        
        o1.bond_to(h4)
        
        @methanol.atoms += [c1,h1,h2,h3,h4,o1]
    end
    
    def create_cyclohexane
        c1 = create_ch2
        c2 = create_ch2
        c3 = create_ch2
        c4 = create_ch2
        c5 = create_ch2
        c6 = create_ch2
        
        c1[0].bond_to c2[0]
        c2[0].bond_to c3[0]
        c3[0].bond_to c4[0]
        c4[0].bond_to c5[0]
        c5[0].bond_to c6[0]
        c6[0].bond_to c1[0]
        @cyclohexane = Molecule.new
        @cyclohexane.atoms += [c1,c2,c3,c4,c5,c6].flatten
    end
    
    def create_ch2
        c1 = Atom.new("C")
        h1 = Atom.new("H")
        h2 = Atom.new("H")
        c1.bond_to(h1)
        c1.bond_to(h2)
        [c1,h1,h2]
    end
    
    def create_ch3
        
    end
end

class Atom
    attr_accessor :neutrons, :protons, :v_electrons, :bonds
    
    @@total = 0
    @@idt = {}
    
    def initialize(id)
        @id = id
        @@total = 1 + (@@total||0)
        @@idt[id] = 1 + (@@idt[id]||0)
        @idn = @@total.to_s + "." + @@idt[id].to_s
        @bonds = []
    end
    
    def inspect
        self.to_s + "(" + @bonds.map {|a| a }.join + ")"
    end
    
    def to_s
        @id + "{" + @idn + "}"
    end
    
    def bond_to(atom)
        @bonds << atom
        atom.bonds << self
    end
end


class Molecule
    attr_accessor :atoms
    def initialize spec=nil
        @spec = spec
        @atoms = []
        @backbone_criterion = ["C"]
        #parse
    end
    
    # spec did change
    
    def parse str
        # find carbon skeleton
        if str =~ /^(.*)(cyclo)?(.*)ane$/
            
        end
    end
    
    def inspect
        self.to_s
    end
    
    def to_s
        @atoms.collect {|a| a.to_s }.join " "
    end
    
    def rec_traverse(atom, path=[])
        max = 0
        min = 0
        rings = []

        last = (path.last != nil) ? [path.last] : []
        #puts "Current atom: #{atom}; got here from: #{last[0]||'nowhere'}"
        
        if not path.include? atom
            already_traversed_via_rings = []
            ##already_traversed_via_rings << path.last if path.last != nil
            #last = (path.last != nil) ? [path.last] : []
            #puts "Current atom: #{atom}; got here from: #{last[0]||'nowhere'}"
            #pathstr = path.map{|a|a.to_s}.join
            #puts "Adding #{atom} to the path #{pathstr}"
            path << atom
            
            bondsstr = "<"+ (atom.bonds - last).map{|a|a.to_s}.join(", ") + ">"
            #puts "Current atom bonds: #{bondsstr}"
            (atom.bonds - last).each do |bonded|
                # After the first traversal, all other children may already have been traversed
                # due to being part of a ring structure. These ring-children are ignored.
                # Premature optimization ftw lol
                unless already_traversed_via_rings.include? bonded
                    pathstr = path.map{|a|a.to_s}.join
                    #puts "Recursively calling for #{bonded}, path is #{pathstr}"
                    info = rec_traverse bonded, path.dup
                    # find any rings beginning and terminating here
                    #p info[:rings]
                    info[:rings].each do |ring|
                        # if the first element in the ring array is the same as atom,
                        # then the ring structure terminates here. The terminating child
                        # is skipped by adding it to already_traversed_...
                        #p ring
                        already_traversed_via_rings << ring.last if ring.first == atom
                    end
                    # Continue passing all ring structures up the recursive call
                    rings += info[:rings].find_all {|ring| ring != []}
                    #rings.flatten!
                    if info[:max] > max
                        min = max if min == 0 # max could be 0, so this will happen many times
                        max = info[:max]
                    end
                end
            end
            #puts "Done iterating children. Path is " + path.map{|a|a.to_s}.join
        elsif path.size > 2
            #puts "Path size > 2, path is " + path.map{|a|a.to_s}.join
            
            # atom is in path, which means we just traversed a loop: a ring structure.
            max = -1
            #puts "ELSIF"
            #p rings
            pt = path[path.rindex(atom)..-1]
            #puts pt
            rings << path[path.rindex(atom)..-1] # change this to find [*last* atom]..end
            #p rings
            #puts "END ELSIF"
        end
        return {:max => max+1, :rings => rings, :min => min}
    end
end