require 'pp'
=begin
=end

module Registry
  module Series
    module DecisionsOfTheCourtOfVeteransAppeals
      #class << self; attr_accessor :volumes end
      #@volumes = {}


      def self.sudoc_stem
      end

      def self.oclcs 
        [27093456]
      end
      
      def parse_ec ec_string
        # our match
        m = nil

        ec_string.chomp!

        # useless junk
        ec_string.sub!(/^TN23 \. U43 /, '') 

        #tokens
        div = '[\s:,;\/-]+\s?\(?'
        n = 'N(umber|O)\.?'+div+'(?<number>\d{2}-\d{2,4})'
        y = 'Y(ear|R)\.?\s?(?<year>\d{4})'
        month = '(?<month>(JAN|FEB|MAR(CH)?|APR(IL)?|MAY|JUNE?|JULY?|AUG|SEPT?|OCT|NOV|DEC)\.?)'

        patterns = [
        #canonical
        # Number:98-8551
        # Number:98-8551-3, Decision Date:2005-05-16
        %r{
          ^#{n}
          (-(?<decision>\d))?
          (,\sDecision\sDate:(?<year>\d{4})(-(?<month>\d{2}))?(-(?<day>\d{2}))?)?$
        }x,

        # NO. 98-1348 (2001:JAN. 10)
        # NO. 95-1100/999 (1999:APR. 1)
        # NO. 95-1068/999-2 (1999:MAR. 24)
        %r{
          ^#{n}
          (\/(?<decision_year>\d{3,4}))?
          ([\/-](?<decision>\d))?\s?
          (\((?<year>\d{4}):#{month}\s?
          (?<day>\d{1,2})?\))?$
        }x,

        # 98-1348
        # 95-1068/998
        # 92-561/2
        %r{
          ^(?<number>\d{2}-\d{2,4})
          (\/(?<year>\d{3,4}))?
          ([\/-](?<decision>\d))?$
        }x,

        # 1990:753/2
        # 1998:57/2002-2
        %r{
          ^(?<case_year>\d{4}):
          (?<number>\d+)
          (\/(?<year>\d{3,4}))?
          ([\/-](?<decision>\d))?$
        }x,

        # stupid
        # 91-5041992:FEB. 21
        %r{
          ^(?<number>\d{2}-\d{2,4})
          ((?<year>\d{4}):#{month}\s?
          (?<day>\d{1,2})?)?$
        }x,

        #simple year
        %r{
          ^#{y}$
        }x
        ] # patterns

        patterns.each do |p|
          if !m.nil?
            break
          end
          m ||= p.match(ec_string)
        end 


        if !m.nil?
          ec = Hash[ m.names.zip( m.captures ) ]
          ec.delete_if {|k, v| v.nil? }

          # the two years in the enumchron need to match
          if ec['decision_year']
            ec['decision_year'] = Series.correct_year(ec['decision_year'])
          end

          if ec['year']
            ec['year'] = Series.correct_year(ec['year'])
          end

          if ec['decision_year'] and !ec['year']
            ec['year'] = ec['decision_year']
          end

          if ec['month'] and ec['month'] =~ /^[0-9]+$/
            ec['month'] = MONTHS[ec['month'].to_i-1]
          end

          # sometimes the number lacks the case year prefix, reassemble
          # e.g. 1990:753/2
          if ec['number'] and ec['number'] !~ /-/ and ec['case_year'].length == 4
            ec['number'] = ec['case_year'][2,2,]+'-'+ec['number']
          end

          if ec['year'] and ec['decision_year'] and ec['year'] != ec['decision_year']
            # We don't actually understand this enumchron
            ec = nil
          end

        end
        ec
      end

      def explode(ec, src=nil)
        enum_chrons = {} 
        if ec.nil?
          return {}
        end

        ecs = []
        ecs << ec

        ecs.each do | ec |
          if canon = self.canonicalize(ec)
            ec['canon'] = canon 
            enum_chrons[ec['canon']] = ec.clone
          end
        end
         
        enum_chrons
      end

      def canonicalize ec
        # Number:8560
        if ec['number']
          canon = "Number:#{ec['number']}"
          if ec['decision']
            canon += "-#{ec['decision']}"
          end
        end
        if ec['year']
          canon += ", Decision Date:#{ec['year']}"
          if ec['month']
            month_num = (MONTHS.index(Series.lookup_month(ec['month']))+1).to_s.rjust(2,'0')
            canon += "-#{month_num}"
            if ec['day']
              canon += "-#{ec['day'].rjust(2,'0')}"
            end
          end
        end
        canon
      end
 
      def self.load_context 
      end
      self.load_context
    end
  end
end