require "demeler"
require "bacon"

# bacon -Ilib spec/demeler.rb

class Obj<Hash
  attr_accessor :errors
  def initialize
    @errors = {}
  end
end

describe "Simple Demeler with no Object" do
  before do
    @d = Demeler.new
  end

  it "should be empty" do
    @d.out.should.be.empty
  end

  it "should return p" do
    @d.clear
    @d.p
    @d.to_s.should.equal "<p />"
  end

  it "should return p with embedded text" do
    @d.clear
    @d.p { "ABC" }
    @d.to_s.should.equal "<p>ABC</p>"
  end

  it "should return p with embedded HTML" do
    @d.clear
    @d.p { @d.br }
    @d.to_s.should.equal "<p><br /></p>"
  end

  it "should be a plain link" do
    @d.clear
    @d.alink("Registration", :href=>"registration")
    @d.to_s.should.equal "<a href=\"registration\">Registration</a>"
  end

  it "should be a plain checkbox control" do
    @d.clear
    @d.checkbox(:vehicle, {}, :volvo=>"Volvo", :saab=>"Saab", :mercedes=>"Mercedes", :audi=>"Audi")
    @d.to_s.should.equal "<input name=\"vehicle[1]\" type=\"checkbox\" value=\"volvo\">Volvo</input><input name=\"vehicle[2]\" type=\"checkbox\" value=\"saab\">Saab</input><input name=\"vehicle[3]\" type=\"checkbox\" value=\"mercedes\">Mercedes</input><input name=\"vehicle[4]\" type=\"checkbox\" value=\"audi\">Audi</input>"
  end

  it "should be a plain radio control" do
    @d.clear
    @d.radio(:vehicle, {}, :volvo=>"Volvo", :saab=>"Saab", :mercedes=>"Mercedes", :audi=>"Audi")
    @d.to_s.should.equal "<input name=\"vehicle\" type=\"radio\" value=\"volvo\">Volvo</input><input name=\"vehicle\" type=\"radio\" value=\"saab\">Saab</input><input name=\"vehicle\" type=\"radio\" value=\"mercedes\">Mercedes</input><input name=\"vehicle\" type=\"radio\" value=\"audi\">Audi</input>"
  end

  it "should be a plain select control" do
    @d.clear
    @d.select(:vehicle, {}, :volvo=>"Volvo", :saab=>"Saab", :mercedes=>"Mercedes", :audi=>"Audi")
    @d.to_s.should.equal "<select name=\"vehicle\"><option value=\"volvo\">Volvo</option><option value=\"saab\">Saab</option><option value=\"mercedes\">Mercedes</option><option value=\"audi\">Audi</option></select>"
  end

  it "should be a plain submit control" do
    @d.clear
    @d.submit("Go!")
    @d.to_s.should.equal "<input type=\"submit\" value=\"Go!\" />"
  end

  it "should add an :id if there is a matching label" do
    @d.clear
    @d.submit("Go!")
    @d.label(:username, "Enter Username")
    @d.text(:username)
    @d.to_s.should.equal "<input type=\"submit\" value=\"Go!\" /><label for=\"username\">Enter Username</label><input name=\"username\" type=\"text\" id=\"username\" />"
  end

end

describe "Complex Demeler with Object" do
  before do
    obj = Obj.new
    obj[:a_button] = "Push Me"
    obj[:a_checkbox1] = {"2"=>"saab","4"=>"audi"}
    obj[:a_checkbox2] = ["saab", "mercedes"]
    obj[:a_checkbox3] = "volvo,mercedes"
    obj[:a_color] = "#00FF00"
    obj[:a_date1] = "2017-06-01"
    obj[:a_date2] = "2017-07-02"
    obj[:an_email] = "mike@czarmail.com"
    obj[:a_hidden] = "hidden_data"
    obj[:a_month] = "2017-06"
    obj[:a_number] = "3"
    obj[:a_password] = "fricken-password"
    obj[:a_radio] = "saab"
    obj[:a_range] = 2
    obj[:a_search] = "search for this"
    obj[:a_tel] = "951-929-2015"
    obj[:a_text] = "This is just scat."
    obj[:a_textarea1] = "Text for area 1."
    obj[:a_textarea2] = "More text for area 2.\nThis text has multiple lines."
    obj[:a_textarea4] = "Line 1"
    obj[:a_time] = "23:24"
    obj[:a_url] = "https://www.czarmail.com"
    obj[:a_week] = "2018-W03"

    @d = Demeler.new(obj)
  end

  it "generate a style block" do
    @d.clear
    @d.style { "red { color: red; } warn { color: red; }" }
    @d.to_s.should.equal "<style>red { color: red; } warn { color: red; }</style>"
  end

  it "should be a button control with data" do
    @d.clear
    @d.button(:name=>:a_button)
    @d.to_s.should.equal "<input name=\"a_button\" type=\"button\" value=\"Push Me\" />"
  end

  it "should be a checkbox control with data" do
    @d.clear
    @d.checkbox(:a_checkbox1, {:class=>:check_class}, :volvo=>"Volvo", :saab=>"Saab", :mercedes=>"Mercedes", :audi=>"Audi")
    @d.to_s.should.equal "<input class=\"check_class\" name=\"a_checkbox1[1]\" type=\"checkbox\" value=\"volvo\">Volvo</input><input class=\"check_class\" name=\"a_checkbox1[2]\" type=\"checkbox\" value=\"saab\" checked=\"true\">Saab</input><input class=\"check_class\" name=\"a_checkbox1[3]\" type=\"checkbox\" value=\"mercedes\">Mercedes</input><input class=\"check_class\" name=\"a_checkbox1[4]\" type=\"checkbox\" value=\"audi\" checked=\"true\">Audi</input>"
  end

  it "should be a color control with data" do
    @d.clear
    @d.color(:a_color)
    @d.to_s.should.equal "<input name=\"a_color\" type=\"color\" value=\"#00FF00\" />"
  end

  it "should be a date control with data" do
    @d.clear
    @d.date(:a_date1)
    @d.to_s.should.equal "<input name=\"a_date1\" type=\"date\" value=\"2017-06-01\" />"
  end

  it "should be a date control with data and class" do
    @d.clear
    @d.date(:a_date2, :class=>:date_class)
    @d.to_s.should.equal "<input name=\"a_date2\" class=\"date_class\" type=\"date\" value=\"2017-07-02\" />"
  end

  it "should be a text control with data" do
    @d.clear
    @d.email(:an_email)
    @d.to_s.should.equal "<input name=\"an_email\" type=\"email\" value=\"mike@czarmail.com\" />"
  end

  it "should be a hidden field with data" do
    @d.clear
    @d.hidden(:a_hidden, :value=>3)
    @d.to_s.should.equal "<input name=\"a_hidden\" value=\"3\" type=\"hidden\" />"
  end

  it "should be an image button" do
    @d.clear
    @d.image(:src=>"images/czar-mail-logo.svg", :width=>80, :height=>30)
    @d.to_s.should.equal "<input src=\"images/czar-mail-logo.svg\" width=\"80\" height=\"30\" type=\"image\" />"
  end

  it "should be an image control" do
    @d.clear
    @d.img(:src=>"images/czar-mail-logo.svg", :width=>80, :height=>30)
    @d.to_s.should.equal "<img src=\"images/czar-mail-logo.svg\" width=\"80\" height=\"30\" />"
  end

  it "should be a month control with data" do
    @d.clear
    @d.month(:a_month)
    @d.to_s.should.equal "<input name=\"a_month\" type=\"month\" value=\"2017-06\" />"
  end

  it "should be a number control with data" do
    @d.clear
    @d.number(:a_number, :min=>1, :max=>5) 
    @d.to_s.should.equal "<input name=\"a_number\" min=\"1\" max=\"5\" type=\"number\" value=\"3\" />"
  end

  it "should be a password control with data" do
    @d.clear
    @d.password(:a_password)
    @d.to_s.should.equal "<input name=\"a_password\" type=\"password\" value=\"fricken-password\" />"
  end

  it "should be a radio control with data" do
    @d.clear
    @d.radio(:a_radio, {:class=>:radio_class}, :volvo=>"Volvo", :saab=>"Saab", :mercedes=>"Mercedes", :audi=>"Audi")
    @d.to_s.should.equal "<input class=\"radio_class\" name=\"a_radio\" type=\"radio\" value=\"volvo\">Volvo</input><input class=\"radio_class\" name=\"a_radio\" type=\"radio\" value=\"saab\" checked=\"true\">Saab</input><input class=\"radio_class\" name=\"a_radio\" type=\"radio\" value=\"mercedes\">Mercedes</input><input class=\"radio_class\" name=\"a_radio\" type=\"radio\" value=\"audi\">Audi</input>"
  end

  it "should be a range control with data" do
    @d.clear
    @d.range(:a_range, :min=>1, :max=>10)
    @d.to_s.should.equal "<input name=\"a_range\" min=\"1\" max=\"10\" type=\"range\" value=\"2\" />"
  end

  it "should be a reset control" do
    @d.clear
    @d.reset
    @d.to_s.should.equal "<input type=\"reset\" />"
  end

  it "should be a search control with data" do
    @d.clear
    @d.search(:a_search)
    @d.to_s.should.equal "<input name=\"a_search\" type=\"search\" value=\"search for this\" />"
  end

  it "should be a submit control" do
    @d.clear
    @d.submit("Go!", :name=>:a_submit)
    @d.to_s.should.equal "<input type=\"submit\" value=\"Go!\" name=\"a_submit\" />"
  end

  it "should be a tel (telephone) control with data" do
    @d.clear
    @d.tel(:a_tel)
    @d.to_s.should.equal "<input name=\"a_tel\" type=\"tel\" value=\"951-929-2015\" />"
  end

  it "should be a text control with data" do
    @d.clear
    @d.text(:a_text, :size=>20)
    @d.to_s.should.equal "<input name=\"a_text\" size=\"20\" type=\"text\" value=\"This is just scat.\" />"
  end

  it "should be a textarea (1) control with data" do
    @d.clear
    @d.textarea(:a_textarea1, :rows=>4, :cols=>50)
    @d.to_s.should.equal "<textarea name=\"a_textarea1\" rows=\"4\" cols=\"50\">Text for area 1.</textarea>"
  end

  it "should be a textarea (2) control with data" do
    @d.clear
    @d.textarea(:a_textarea2, :rows=>4, :cols=>50) {'2'}
    @d.to_s.should.equal "<textarea name=\"a_textarea2\" rows=\"4\" cols=\"50\">More text for area 2.\nThis text has multiple lines.</textarea>"
  end

  it "should be a textarea (3) control with NO data" do
    @d.clear
    @d.textarea(:a_textarea3, :rows=>4, :cols=>50, :text=>["Line 1","Line 2","Line 3"])
    @d.to_s.should.equal "<textarea name=\"a_textarea3\" rows=\"4\" cols=\"50\">Line 1\nLine 2\nLine 3</textarea>"
  end

  it "should be a textarea (4) control with data" do
    @d.clear
    @d.textarea(:a_textarea4, :rows=>4, :cols=>50)
    @d.to_s.should.equal "<textarea name=\"a_textarea4\" rows=\"4\" cols=\"50\">Line 1</textarea>"
  end

  it "should be a time control with data" do
    @d.clear
    @d.time(:a_time)
    @d.to_s.should.equal "<input name=\"a_time\" type=\"time\" value=\"23:24\" />"
  end

  it "should be a url control with data" do
    @d.clear
    @d.url(:a_url)
    @d.to_s.should.equal "<input name=\"a_url\" type=\"url\" value=\"https://www.czarmail.com\" />"
  end

  it "should be a week control with data" do
    @d.clear
    @d.week(:a_week)
    @d.to_s.should.equal "<input name=\"a_week\" type=\"week\" value=\"2018-W03\" />"
  end

  it "should be a red tag with data" do
    @d.clear
    @d.red(:text=>"This ought to be red.") 
    @d.to_s.should.equal "<red>This ought to be red.</red>"
  end

#=== Demeler Calls =====================================

  it "should be demeler: args is a hash (attributes only)" do
    @d.clear
    @d.tag_generator(:div, {:class=>"div-class"}) { "..." }
    @d.to_s.should.equal "<div class=\"div-class\">...</div>"
  end

  it "should be demeler: args is empty array" do
    @d.clear
    @d.tag_generator(:br, [])
    @d.to_s.should.equal "<br />"
  end

  it "should be demeler: args is array of 1 string" do
    @d.clear
    @d.tag_generator(:textarea, ["Some text to edit."])
    @d.to_s.should.equal "<textarea>Some text to edit.</textarea>"
  end

  it "should be demeler: args is array of 1 symbol (used as 'name')" do
    @d.clear
    @d.tag_generator(:div, [:div_name]) { "..." }
    @d.to_s.should.equal "<div name=\"div_name\">...</div>"
  end

  it "should be demeler: args is array of 1 hash (same as args is a hash)" do
    @d.clear
    @d.tag_generator(:div, [{:class=>"div-name"}]) { "..." }
    @d.to_s.should.equal "<div class=\"div-name\">...</div>"
  end

  it "should be demeler: args is an array of symbol ('name') and hash ('attributes')" do
    @d.clear
    @d.tag_generator(:div, [:list, :class=>'list-class']) { "..." }
    @d.to_s.should.equal "<div name=\"list\" class=\"list-class\">...</div>"
  end

  it "should be demeler: args is array of symbol ('name') and string ('text' or 'for')" do
    @d.clear
    @d.tag_generator(:label, [:list, "List"])
    @d.to_s.should.equal "<label for=\"list\">List</label>"
  end

  it "should have an error message" do
    @d.clear
    @d.obj.errors[:err] = ["Username already used."]
    @d.tag_generator(:input, {:name=>:err, :value=>"bobama", :type=>:text})
    @d.to_s.should.equal "<input name=\"err\" value=\"bobama\" type=\"text\" /><warn> <-- Username already used.</warn>"
  end

  it "should create user friendly HTML" do
    @d.clear
    @d.obj.errors[:err] = ["Username already used."]
    @d.tag_generator(:input, {:name=>:err, :value=>"bobama", :type=>:text})
    @d.to_html.should.equal "<!-- begin generated output -->\n<input name=\"err\" value=\"bobama\" type=\"text\" /><warn> <-- Username already used.</warn>\n<!-- end generated output -->\n"
  end

end
