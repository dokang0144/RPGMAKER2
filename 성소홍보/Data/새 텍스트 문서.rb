#==============================================================================
# �� Name Window Setting
#==============================================================================
module NWS
  
  BACKGROUND = true  #����� ǥ�ÿ���(true: ǥ��, false: ǥ��X)
  OPACITY = 200 #�������� ����(0~255)
  
  #ĳ���� �׸��� �̸��� ǥ�õǴ� ������ ������ �κ�
  NEW_X = 136 #x��ǥ
  NEW_Y = 72 # Y��ǥ
  
  #����, ����, ���� ������ ��Ұ� ǥ�õǴ� �Ʒ����� ������ �κ�
  NIW_X = 136 #x��ǥ
  NIW_Y = 200 # Y��ǥ
  
  #����, ����, ���� ������ ���
  #������ �ٲ㵵 ������, ABCD����� ���Ӱ� �߰��ص� �������ϴ�.
  #�ٸ� �ٲ�Ͱ� ���� �Ʒ��� VER_LINE, HOR_LINE, CONFIRM ������ 
  #������ �ݽô�.
  TABLE = [ '1','2','3','4','5', '6','7','8','9','0',
              '��','��','��','��','��', '��','��','��','��','��',
              '��','��','��','��','��',  '','','','��','��',
              '��','��','��','��','��', '��','��','��','��','',
              '��','��','��','��','','��','��','��','','����']
  VER_LINE = 5 #������ ����
  HOR_LINE = 10 #������ ����
  CONFIRM = 49 #'����'�� ��ġ
  
end
#==============================================================================
# �� Window_NameEdit
#==============================================================================
class Window_NameEdit < Window_Base
#---------------------------------------------------------------------------
  CONSO = ["��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��"]
  HEAD = ["��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��"]
  TABLE = ["��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��"]
  TABLE_SIDE = ["��","��","��","��"]
  ANOTHER_TABLE_SIDE = [[nil,"��"],["��","��"],["��","��","��","��","��","��","��"],[nil,"��"]]
  VOWEL = ["��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��","��"]
  COM_VOWEL = ["��","��","��"]
  ANOTHER_COM_VOWEL = [["��","��","��"],["��","��","��"],"��"]
#--------------------------------------------------------------------------
  attr_reader   :name                     # �̸�
  attr_reader   :prompt                     # ������Ʈ
  attr_reader   :index                     # Ŀ�� ��ġ
  attr_reader   :max_char               # �ִ� ���ڼ�
#--------------------------------------------------------------------------
  def initialize(actor, max_char)
    super(NWS::NEW_X, NWS::NEW_Y, (NWS::HOR_LINE + 1) * 32, 128)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.opacity = NWS::OPACITY
    @actor = actor
    @prompt = []
    @max_char = max_char
    name_array = actor.name.split(//)[0...@max_char]
    @name = []
    @default_name = []
    for i in 0...name_array.size
      @name << name_array[i]
      @default_name << name_array[i]
    end
    self.active = false
    refresh
  end
#--------------------------------------------------------------------------
  def restore_default
    @name = @default_name.dup
    @prompt = []
    refresh
  end
#--------------------------------------------------------------------------
  def add(character)
    @prompt << character
    refresh
  end
#--------------------------------------------------------------------------
  def back
    @prompt == [] ? @name.pop : @prompt.pop
    refresh
  end
#--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.x = 188 - (@max_char + 1) * 12 + index * 32
    rect.y = 32
    rect.width = 32
    rect.height = 32
    return rect
  end
#--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_actor_graphic(@actor, 60, 70)
    name = prompt_to_letter
    if @name.size == @max_char
          @prompt = []
          name = ""
          @index = @name.size - 1
    else
          @index = @name.size
    end
    for i in 0...@name.size
      self.contents.draw_text(item_rect(i), @name[i], 1)
    end
    self.contents.draw_text(item_rect(@name.size), name, 1)
    update_cursor
  end
#--------------------------------------------------------------------------
  def update_cursor
    self.cursor_rect = item_rect(@index)
  end
#--------------------------------------------------------------------------
  def update
    super
    update_cursor
  end
 
#============================================================================
# �� prompt_to_letter, 1st~5th phase, where?(array = from, c = what)
#----------------------------------------------------------------------------
# �� ���ϴ� ���ڸ� �����ϴ� �����Դϴ�.
# �ٸ� �κ��� ���������, �� ������ �κ��� �������� �ʱ� �����մϴ�.
# �Ϻ� ��Ʈ���� Ư�� ���ڰ� ǥ������ �ʽ��ϴ�. (��,�U ���..)
#
# 2009. 3. 18 by Heircoss
#============================================================================
  def prompt_to_letter
    size = @prompt.size
    case size
    when 0
          return ""
    when 1
          return @prompt[0]
    when 2
          first_phase
    when 3
          second_phase
    when 4
          third_phase
    when 5
          fourth_phase
    when 6
          fifth_phase
    end
  end
  def first_phase
    if CONSO.include?(@prompt[0])
          if CONSO.include?(@prompt[1])
                c0, c1 = conso_plus_conso
          else
                return conso_plus_vowel
          end
    else
          c0, c1 = vowel_plus_vowel
    end
    if c1 == nil
          return c0
    else
          @name << @prompt.shift
    end                  
    return @prompt[0]
  end
  def second_phase
    if CONSO.include?(@prompt[0])
          if CONSO.include?(@prompt[1])
                if CONSO.include?(@prompt[2])
                      @name << conso_plus_conso(@prompt.shift, @prompt.shift)
                else
                      @name << @prompt.shift
                      return conso_plus_vowel
                end
          else
                if TABLE.include?(@prompt[2])
                      return conso_plus_vowel_plus_table
                else
                      c0, c1 = vowel_plus_vowel(@prompt[1], @prompt[2])
                      if c1 == nil
                            return conso_plus_vowel(@prompt[0],c0)
                      else
                            @name << conso_plus_vowel(@prompt.shift, @prompt.shift)
                      end
                end
          end
    else
          @name << vowel_plus_vowel(@prompt.shift, @prompt.shift)
    end
    return @prompt[0]
  end
  def third_phase
    if CONSO.include?(@prompt[2])
          if CONSO.include?(@prompt[3])
                c0, c1 = conso_plus_conso(@prompt[2], @prompt[3])
                if c1 == nil
                      conso, vowel, table = @prompt[0],@prompt[1],c0
                      return conso_plus_vowel_plus_table(conso, vowel, table)
                else
                      conso, vowel, table = @prompt.shift, @prompt.shift, @prompt.shift
                      @name << conso_plus_vowel_plus_table(conso, vowel, table)
                end          
          else
                conso, vowel = @prompt.shift, @prompt.shift
                @name << conso_plus_vowel(conso, vowel)
                return  conso_plus_vowel
          end
    else
          if TABLE.include?(@prompt[3])
                conso = @prompt[0]
                vowel = vowel_plus_vowel(@prompt[1], @prompt[2])
                table = @prompt[3]
                return conso_plus_vowel_plus_table(conso, vowel, table)
          else
                conso = @prompt.shift
                vowel = vowel_plus_vowel(@prompt.shift, @prompt.shift)
                @name << conso_plus_vowel(conso, vowel)
          end
    end
    return @prompt[0]
  end
  def fourth_phase
    if CONSO.include?(@prompt[4])
          if CONSO.include?(@prompt[2])
                conso = @prompt.shift
                vowel = @prompt.shift
                table = conso_plus_conso(@prompt.shift,@prompt.shift)
                @name << conso_plus_vowel_plus_table(conso, vowel, table)
          else
                c0, c1 = conso_plus_conso(@prompt[3], @prompt[4])
                if c1 == nil
                      conso = @prompt[0]
                      vowel = vowel_plus_vowel(@prompt[1], @prompt[2])
                      table =  c0
                      return conso_plus_vowel_plus_table(conso, vowel, table)
                else
                      conso = @prompt.shift
                      vowel = vowel_plus_vowel(@prompt.shift, @prompt.shift)
                      table = @prompt.shift
                      @name << conso_plus_vowel_plus_table(conso, vowel, table)
                end
          end
    else
          @name << second_phase
          @prompt = @prompt[3..4]
          return first_phase
    end
    return @prompt[0]  
  end
  def fifth_phase
    if CONSO.include?(@prompt[5])
      conso = @prompt.shift
      vowel = vowel_plus_vowel(@prompt.shift, @prompt.shift)
      table = conso_plus_conso(@prompt.shift, @prompt.shift)
      @name << conso_plus_vowel_plus_table(conso, vowel, table)
    else
      @name << third_phase
      @prompt = @prompt[4..5]
      return first_phase
    end
    return @prompt[0]
  end
  def conso_plus_conso(c0 = @prompt[0], c1 = @prompt[1])
    index0 = where?(TABLE_SIDE,c0)
    if index0 != nil
          index1 = where?(ANOTHER_TABLE_SIDE[index0],c1)
          if index1 != nil
                index0 = where?(CONSO, c0)
                return CONSO[index0 + index1 + 1]
          end
    end
    return c0, c1
  end
  def vowel_plus_vowel(c0 = @prompt[0], c1 = @prompt[1])
    index0 = where?(COM_VOWEL,c0)
    if index0 != nil
          index1 = where?(ANOTHER_COM_VOWEL[index0],c1)
          if index1 != nil
                index0 = where?(VOWEL, c0)
                return VOWEL[index0 + index1 + 1]
          end
    end
    return c0, c1                 
  end                  
  def conso_plus_vowel(c0 = @prompt[0], c1 = @prompt[1])
    index0 = where?(HEAD,c0)
    index1 = where?(VOWEL,c1)                        
    return [44032 + (588 * index0) + (28 * index1)].pack('U*')
  end
  def conso_plus_vowel_plus_table(c0 = @prompt[0], c1 = @prompt[1], c2 = @prompt[2])
    index0 = where?(HEAD,c0)
    index1 = where?(VOWEL,c1)
    index2 = where?(TABLE,c2)
    return [44032 + (588 * index0) + (28 * index1) + index2 + 1].pack('U*')
  end
  def where?(array, c)
    if array.class != Array && array == c
          return 0
    else
          array.each_with_index do |item, index|
                return index if item == c
          end
    end
    return nil
  end            
end
#============================================================================
# �� �������
#============================================================================

#============================================================================
# �� Window_NameInput
#============================================================================
class Window_NameInput < Window_Base
#--------------------------------------------------------------------------
  def initialize
    super(NWS::NIW_X, NWS::NIW_Y, (NWS::HOR_LINE + 1) * 32, (NWS::VER_LINE + 1) * 32 )
    self.contents = Bitmap.new(width - 32, height - 32)
    self.opacity = NWS::OPACITY
    @index = 0
    refresh
    update_cursor
  end
#--------------------------------------------------------------------------
  def character
    return NWS::TABLE[@index]
  end
#--------------------------------------------------------------------------
  def is_decision
    return (@index == NWS::CONFIRM)
  end
#--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.x = index % NWS::HOR_LINE * 32
    rect.y = index / NWS::HOR_LINE * 32
    rect.width = 32
    rect.height = 32
    return rect
  end
#--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0...NWS::TABLE.size
      rect = item_rect(i)
      rect.x += 2
      rect.width -= 4
      self.contents.draw_text(rect, NWS::TABLE[i], 1)
    end
  end
#--------------------------------------------------------------------------
  def update_cursor
    self.cursor_rect = item_rect(@index)
  end
#--------------------------------------------------------------------------
  def cursor_down(wrap)
    if @index < NWS::VER_LINE * NWS::HOR_LINE - NWS::HOR_LINE
      @index += NWS::HOR_LINE
    elsif wrap
      @index -= NWS::VER_LINE * NWS::HOR_LINE - NWS::HOR_LINE
    end
  end
#--------------------------------------------------------------------------
  def cursor_up(wrap)
    if @index >= NWS::HOR_LINE
      @index -= NWS::HOR_LINE
    elsif wrap
      @index += NWS::VER_LINE * NWS::HOR_LINE - NWS::HOR_LINE
    end
  end
#--------------------------------------------------------------------------
  def cursor_right(wrap)
    if @index % NWS::HOR_LINE < (NWS::HOR_LINE - 1)
      @index += 1
    elsif wrap
      @index -= (NWS::HOR_LINE - 1)
    end
  end
#--------------------------------------------------------------------------
  def cursor_left(wrap)
    if @index % NWS::HOR_LINE > 0
      @index -= 1
    elsif wrap
      @index += (NWS::HOR_LINE - 1)
    end
  end
#--------------------------------------------------------------------------
  def cursor_to_decision
    @index = NWS::CONFIRM
  end
#--------------------------------------------------------------------------
  def update
    super
    last_mode = @mode
    last_index = @index
    if Input.repeat?(Input::DOWN)
      cursor_down(Input.trigger?(Input::DOWN))
    end
    if Input.repeat?(Input::UP)
      cursor_up(Input.trigger?(Input::UP))
    end
    if Input.repeat?(Input::RIGHT)
      cursor_right(Input.trigger?(Input::RIGHT))
    end
    if Input.repeat?(Input::LEFT)
      cursor_left(Input.trigger?(Input::LEFT))
    end
    if Input.trigger?(Input::A)
      cursor_to_decision
    end
    if @index != last_index
      $game_system.se_play($data_system.cursor_se)
    end
    update_cursor
  end
end

#===========================================================================
# �� Scene_Name
#===========================================================================
class Scene_Name
#---------------------------------------------------------------------------
  def main
    @actor = $game_actors[$game_temp.name_actor_id]
    back = Spriteset_Map.new if NWS::BACKGROUND == true
    @edit_window = Window_NameEdit.new(@actor, $game_temp.name_max_char)
    @input_window = Window_NameInput.new
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    back.dispose if NWS::BACKGROUND == true
    @edit_window.dispose
    @input_window.dispose
  end
#--------------------------------------------------------------------------
  def terminate
    @menuback_sprite.dispose
    @edit_window.dispose
    @input_window.dispose
  end
#--------------------------------------------------------------------------
  def return_scene
    $scene = Scene_Map.new
  end
#--------------------------------------------------------------------------
  def update
    @edit_window.update
    @input_window.update
    if Input.repeat?(Input::B)
      if @edit_window.name == [] && @edit_window.prompt == []
        $game_system.se_play($data_system.buzzer_se)
      else
        $game_system.se_play($data_system.cancel_se)
        @edit_window.back
      end
    elsif Input.trigger?(Input::C)
      if @input_window.is_decision
        if @edit_window.name.size == 0 && @edit_window.prompt.size == 0        # �̸��� ����ִ� ���
          @edit_window.restore_default
          if @edit_window.name.size == 0 && @edit_window.prompt.size == 0
            $game_system.se_play($data_system.buzzer_se)
          else
            $game_system.se_play($data_system.decision_se)
          end
        else
          $game_system.se_play($data_system.decision_se)
          name = @edit_window.prompt_to_letter
          name = @edit_window.name.to_s + name
          @actor.name = name
          return_scene
        end
      elsif @input_window.character != "" && @input_window.character != nil
        if @edit_window.name.size > @edit_window.max_char
          $game_system.se_play($data_system.buzzer_se)
        else
          $game_system.se_play($data_system.decision_se)
          @edit_window.add(@input_window.character)        
        end
      end
    end
  end
end
