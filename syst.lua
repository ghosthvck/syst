-- Syst
-- 
-- workplace antistress system v1.5
--
-- k1 (long) params menu
-- enc2,enc3 rotates the figure on the main screen
-- key3 - auto rotation on main screen on/off

engine.name = "PolyPerc"

local angle_x = 0
local angle_y = 0
local angle_z = 0
local auto_rotate = true
local auto_speed_x = 0.005
local auto_speed_y = 0.01
local auto_speed_z = 0.007
local current_shape = 1
local shapes = {}
local menu_active = false
local menu_index = 1
local music_playing = false
local sequence_clock
local current_step = 1
local melody_sequence = {}
local bass_sequence = {}
local chord_sequence = {}
local arp_sequence = {}
local pad_sequence = {}
local last_note_time = 0
local phrase_length = 64  
local current_section = 1
local sections = {"intro", "main", "variation", "outro"}
local current_chord_notes = {60, 64, 67} 
local next_chord_change = 1
local harmonic_rhythm = 16
local current_melody_pattern = 1
local current_bass_pattern = 1
local current_arp_pattern = 1
local melody_variation_counter = 0
local bass_variation_counter = 0
local previous_chord_notes = {}
local voice_leading_active = true
local planets = {}
local meteors = {}
local radiation_angle = 0
local radiation_alpha = 0.5
local radiation_alpha_direction = 1
local auto_zoom_phase = 0
local auto_zoom_speed = 0.02
local auto_zoom_active = false
local base_zoom = 90

local scales = {
  major = {0, 2, 4, 5, 7, 9, 11},           
  minor = {0, 2, 3, 5, 7, 8, 10},
  harmonic_minor = {0, 2, 3, 5, 7, 8, 11},
  melodic_minor = {0, 2, 3, 5, 7, 9, 11},
  dorian = {0, 2, 3, 5, 7, 9, 10},          
  phrygian = {0, 1, 3, 5, 7, 8, 10},
  mixolydian = {0, 2, 4, 5, 7, 9, 10},     
  aeolian = {0, 2, 3, 5, 7, 8, 10},
  lydian = {0, 2, 4, 6, 7, 9, 11},         
  pentatonic = {0, 2, 4, 7, 9},            
  minor_pentatonic = {0, 3, 5, 7, 10},
  suspended = {0, 2, 5, 7, 9}                
}

local current_scale = scales.major
local root_note = 60  
local minecraft_progressions = {
  peaceful = {
    {1, "maj7", inv=0}, {5, "sus4", inv=1}, {6, "min7", inv=0}, {4, "maj7", inv=1},     
    {1, "maj7", inv=2}, {3, "min7", inv=1}, {4, "maj7", inv=0}, {5, "7sus4", inv=0},
    {1, "maj7", inv=0}, {2, "min7", inv=1}, {5, "7", inv=2}, {1, "maj7", inv=0}
  },
  nostalgic = {
    {1, "maj", inv=0}, {6, "min7", inv=1}, {4, "maj7", inv=0}, {5, "sus4", inv=0},        
    {1, "maj", inv=1}, {3, "min7", inv=0}, {6, "min", inv=1}, {2, "min7", inv=0},
    {4, "maj7", inv=0}, {5, "7", inv=1}, {3, "min7", inv=0}, {6, "min", inv=1},
    {2, "min7", inv=0}, {5, "7sus4", inv=0}, {1, "maj", inv=0}
  },
  mysterious = {
    {1, "min7", inv=0}, {4, "min7", inv=1}, {1, "min7", inv=2}, {5, "7sus4", inv=0},    
    {1, "min", inv=0}, {7, "maj7", inv=0}, {6, "maj7", inv=1}, {5, "sus4", inv=0},
    {4, "min7", inv=0}, {3, "maj7", inv=1}, {2, "min7b5", inv=0}, {5, "7alt", inv=0},
    {1, "min7", inv=0}
  },
  adventurous = {
    {1, "maj", inv=0}, {5, "maj", inv=1}, {6, "min7", inv=0}, {3, "min7", inv=1},         
    {4, "maj7", inv=0}, {1, "maj", inv=2}, {2, "min7", inv=0}, {5, "7sus4", inv=0},
    {1, "maj", inv=0}, {7, "maj7", inv=0}, {6, "min7", inv=1}, {5, "7", inv=0},
    {1, "maj", inv=0}
  },
  melancholic = {
    {1, "min", inv=0}, {4, "min7", inv=1}, {7, "maj7", inv=0}, {3, "maj7", inv=1},
    {6, "maj7", inv=0}, {2, "min7b5", inv=0}, {5, "7", inv=1}, {1, "min", inv=0},
    {1, "min7", inv=2}, {6, "maj7", inv=0}, {4, "min7", inv=1}, {5, "7alt", inv=0},
    {1, "min", inv=0}
  },
  dark = {
    {1, "min", inv=0}, {2, "dim7", inv=0}, {5, "min7", inv=1}, {1, "min", inv=2},
    {4, "min7", inv=0}, {7, "7", inv=0}, {3, "maj7", inv=1}, {6, "maj", inv=0},
    {2, "min7b5", inv=0}, {5, "7alt", inv=0}, {1, "min", inv=0}
  },
  epic = {
    {1, "min", inv=0}, {7, "maj", inv=0}, {6, "maj7", inv=0}, {5, "maj", inv=1},
    {4, "min7", inv=0}, {3, "maj7", inv=1}, {2, "min7b5", inv=0}, {5, "7", inv=0},
    {1, "min", inv=1}, {6, "maj7", inv=0}, {7, "maj", inv=1}, {1, "min", inv=0},
    {3, "maj7", inv=0}, {4, "min7", inv=1}, {5, "7sus4", inv=0}, {1, "min", inv=0}
  },
  ethereal = {
    {1, "maj9", inv=0}, {4, "maj7#11", inv=0}, {1, "maj7", inv=1}, {5, "sus2", inv=0},
    {6, "min9", inv=0}, {3, "min7", inv=1}, {4, "maj7", inv=2}, {1, "maj7", inv=0},
    {2, "min11", inv=0}, {5, "7sus4", inv=1}, {1, "maj9", inv=0}
  },
  cinematic = {
    {1, "min", inv=0}, {1, "min/7", inv=0}, {1, "min/6", inv=0}, {1, "min/5", inv=0},
    {4, "min7", inv=0}, {4, "min6", inv=0}, {2, "min7b5", inv=0}, {5, "7alt", inv=0},
    {1, "min", inv=1}, {3, "maj7", inv=0}, {6, "maj9", inv=0}, {2, "min7", inv=1},
    {5, "7", inv=0}, {1, "min", inv=0}
  }
}

local current_progression_type = "peaceful"
local current_progression = minecraft_progressions.peaceful
local current_chord_index = 1
local melody_patterns = {
  {timing = {1, 9, 17, 25}, notes = {1, 3, 5, 3}, octave = 1, prob = 0.3, passing = true},
  {timing = {1, 5, 9, 13}, notes = {5, 3, 1, 2}, octave = 1, prob = 0.25},
  {timing = {1, 13, 25}, notes = {1, 5, 8}, octave = 2, prob = 0.2},
  {timing = {1, 3, 5, 7, 9}, notes = {1, 2, 3, 5, 3}, octave = 1, prob = 0.35, ornament = true},
  {timing = {1, 5, 9, 13}, notes = {5, 7, 5, 3}, octave = 1, prob = 0.3},
  {timing = {1, 17}, notes = {5, 1}, octave = 2, prob = 0.15, vibrato = true},
  {timing = {1, 9, 25}, notes = {3, 5, 1}, octave = 1, prob = 0.2},
  {timing = {1, 5, 17, 21}, notes = {1, 3, 3, 1}, octave = 1, prob = 0.25, sequence = true},
  {timing = {1, 9, 17, 25}, notes = {5, 6, 5, 3}, octave = 1, prob = 0.3},
  {timing = {1, 4, 7, 10, 13}, notes = {1, 3, 5, 7, 5}, octave = 1, prob = 0.25, jazz = true},
  {timing = {1, 6, 11, 16}, notes = {9, 7, 5, 3}, octave = 1, prob = 0.2},
  {timing = {1}, notes = {1}, octave = 2, prob = 0.1},
  {timing = {1, 17}, notes = {5, 5}, octave = 1, prob = 0.15}
}

local bass_patterns = {
  {timing = {1}, notes = {1}, octave = -2, prob = 1.0},
  {timing = {1, 9}, notes = {1, 1}, octave = -2, prob = 0.8},
  {timing = {1, 5, 9, 13}, notes = {1, 3, 5, 3}, octave = -2, prob = 0.6, walking = true},
  {timing = {1, 4, 7, 10, 13}, notes = {1, 2, 3, 5, 1}, octave = -2, prob = 0.5, chromatic = true},
  {timing = {1, 9}, notes = {1, 1}, octaves = {-2, -1}, prob = 0.4},
  {timing = {1, 5, 9, 13}, notes = {1, 1, 5, 5}, octaves = {-2, -1, -2, -1}, prob = 0.3},
  {timing = {1, 7, 11}, notes = {1, 5, 1}, octave = -2, prob = 0.35},
  {timing = {1, 3, 9, 11}, notes = {1, 1, 5, 5}, octave = -2, prob = 0.3},
  {timing = {1, 3, 5, 7, 9, 11, 13, 15}, notes = {1, 1, 3, 5, 8, 5, 3, 1}, octave = -2, prob = 0.25, melodic = true}
}

local minecraft_arp_patterns = {
  gentle = {1, 3, 5, 3},                    
  flowing = {1, 5, 3, 5, 1},            
  ambient = {1, 5, 8, 5},                 
  simple = {1, 3, 1, 3},
  cascade = {1, 3, 5, 7, 5, 3},
  bounce = {1, 5, 3, 5, 1, 5},
  minimal = {1, 5},
  extended = {1, 3, 5, 8, 5, 3, 1},
  rhythmic = {1, 1, 3, 5, 5, 3},
  sparse = {1},
  jazz = {1, 3, 5, 7, 9, 7, 5, 3},
  broken = {1, 5, 3, 7, 5, 9, 7, 3},
  ascending = {1, 3, 5, 7, 9},
  descending = {9, 7, 5, 3, 1}
}

local pad_patterns = {
  {notes = "all", timing = {1}, duration = 32, prob = 0.3, voice_lead = true},
  {notes = "all", timing = {1, 17}, duration = 16, prob = 0.25},
  {notes = {1, 3}, timing = {1}, duration = 24, prob = 0.35, smooth = true},
  {notes = {1, 5}, timing = {1, 9}, duration = 8, prob = 0.3},
  {notes = {1, 3, 5}, timing = {1, 5, 9}, duration = 12, prob = 0.25, moving = true},
  {notes = {3, 5, 7}, timing = {1, 17}, duration = 16, prob = 0.2},
  {notes = {1, 3, 5, 7, 9}, timing = {1}, duration = 32, prob = 0.15, extended = true}
}

local system_logs = {
  "a2f9", "b7x3", "c4q8", "d1w5", "e9k2", "f3m7", "g8n1", "h5p4",
  "j2v8", "k6y3", "l9z1", "m4a7", "n8b2", "p3c6", "q7d4", "r1e9",
  "s5f3", "t9g7", "u2h4", "v6j8", "w3k5", "x7l9", "y4m2", "z8n6"
}

local active_annotations = {}
local annotation_counter = 0

local params_list = {
  {id = "shape", name = "Shape", value = 1, min = 1, max = 5, step = 1, formatter = function(v) return shapes[math.floor(v)].name end},
  {id = "zoom", name = "Zoom", value = 90, min = 5, max = 100, step = 1},
  {id = "angle_x", name = "Angle X", value = 0, min = -180, max = 180, step = 1},
  {id = "angle_y", name = "Angle Y", value = 0, min = -180, max = 180, step = 1},
  {id = "angle_z", name = "Angle Z", value = 0, min = -180, max = 180, step = 1},
  {id = "auto_rotate", name = "Auto Rotate", value = 1, min = 0, max = 1, step = 1, formatter = function(v) return v > 0 and "ON" or "OFF" end},
  {id = "speed_x", name = "Speed X", value = 20, min = -5, max = 100, step = 0.1},
  {id = "speed_y", name = "Speed Y", value = 20, min = -5, max = 100, step = 0.1},
  {id = "speed_z", name = "Speed Z", value = 20, min = -5, max = 100, step = 0.1},
  {id = "star_count", name = "Stars", value = 50, min = 0, max = 200, step = 10},
  {id = "star_speed", name = "Star Speed", value = 1, min = 0, max = 10, step = 0.1},
  {id = "star_parallax", name = "Star Parallax", value = 1, min = 0, max = 20, step = 0.1},
  {id = "perspective", name = "Perspective", value = 5, min = 1, max = 20, step = 0.5},
  {id = "line_width", name = "Line Width", value = 1, min = 1, max = 5, step = 1},
  {id = "vertex_size", name = "Vertex Size", value = 1, min = 0, max = 5, step = 0.5},
  {id = "gradient", name = "Gradient", value = 0, min = 0, max = 1, step = 1, formatter = function(v) return v > 0 and "ON" or "OFF" end},
  {id = "annotation_freq", name = "Annotation Freq", value = 0.5, min = 0, max = 2, step = 0.1},
  {id = "max_annotations", name = "Max Annotations", value = 1, min = 0, max = 10, step = 1},
  {id = "annotation_dist", name = "Annotation Dist", value = 30, min = 20, max = 50, step = 5},
  {id = "show_time", name = "Show Time", value = 1, min = 0, max = 1, step = 1, formatter = function(v) return v > 0 and "ON" or "OFF" end},
  {id = "time_format", name = "Time Format", value = 1, min = 1, max = 2, step = 1, formatter = function(v) return v == 1 and "24H" or "12H" end},
  {id = "music_on", name = "Music", value = 1, min = 0, max = 1, step = 1, formatter = function(v) return v > 0 and "ON" or "OFF" end},
  {id = "generate_music", name = "Generate New", value = 0, min = 0, max = 1, step = 1, formatter = function(v) return "K2" end},
  {id = "scale_type", name = "Scale", value = 1, min = 1, max = 12, step = 1, formatter = function(v) 
    local scale_names = {
      "Major", 
      "Minor", 
      "Harmonic Minor",
      "Melodic Minor",
      "Dorian", 
      "Phrygian",
      "Mixolydian", 
      "Aeolian", 
      "Lydian", 
      "Pentatonic",
      "Minor Pent",
      "Suspended"
    }
    return scale_names[math.floor(v)]
  end},
  {id = "root_note", name = "Root Note", value = 60, min = 48, max = 72, step = 1, formatter = function(v)
    local notes = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
    local note_name = notes[(v % 12) + 1]
    local octave = math.floor(v / 12) - 1
    return note_name .. octave
  end},
  {id = "progression_type", name = "Progression", value = 1, min = 1, max = 9, step = 1, formatter = function(v)
    local prog_names = {"Peaceful", "Nostalgic", "Mysterious", "Adventurous", "Melancholic", "Dark", "Epic", "Ethereal", "Cinematic"}
    return prog_names[math.floor(v)]
  end},
  {id = "phrase_length", name = "Phrase Length", value = 64, min = 32, max = 128, step = 16},
  {id = "reverb", name = "Reverb", value = 0.7, min = 0, max = 1, step = 0.1},
  {id = "melody_volume", name = "Melody Vol", value = 0.4, min = 0, max = 1, step = 0.1},
  {id = "bass_volume", name = "Bass Vol", value = 0.3, min = 0, max = 1, step = 0.1},
  {id = "arp_volume", name = "Arp Vol", value = 0.3, min = 0, max = 1, step = 0.1},
  {id = "evolve", name = "Evolution", value = 0.3, min = 0, max = 1, step = 0.1},
  {id = "harmonic_rhythm", name = "Chord Changes", value = 16, min = 8, max = 32, step = 4},
  {id = "pad_volume", name = "Pad Vol", value = 0.2, min = 0, max = 1, step = 0.1},
  {id = "pad_density", name = "Pad Dens", value = 0.5, min = 0, max = 1, step = 0.1},
  {id = "melody_density", name = "Melody Dens", value = 0.5, min = 0, max = 1, step = 0.1},
  {id = "bass_variation", name = "Bass Var", value = 0.5, min = 0, max = 1, step = 0.1},
  {id = "voice_leading", name = "Voice Leading", value = 1, min = 0, max = 1, step = 1, formatter = function(v) return v > 0 and "ON" or "OFF" end},
  {id = "planet_count", name = "Planets", value = 3, min = 0, max = 10, step = 1},
  {id = "meteor_count", name = "Meteors", value = 5, min = 0, max = 20, step = 1},
  {id = "auto_zoom", name = "Auto Zoom", value = 1, min = 0, max = 1, step = 1, formatter = function(v) return v > 0 and "ON" or "OFF" end},
  {id = "zoom_range", name = "Zoom Range", value = 30, min = 10, max = 50, step = 5},
  {id = "zoom_speed", name = "Zoom Speed", value = 0.02, min = 0.01, max = 0.1, step = 0.01}
}

function get_param_value(param_index, default)
  if params_list[param_index] and params_list[param_index].value then
    return params_list[param_index].value
  else
    return default or 0
  end
end

local phi = (1 + math.sqrt(5)) / 2

shapes[1] = {
  name = "Dodecahedron",
  vertices = {
    {1, 1, 1}, {1, 1, -1}, {1, -1, 1}, {1, -1, -1},
    {-1, 1, 1}, {-1, 1, -1}, {-1, -1, 1}, {-1, -1, -1},
    {0, phi, 1/phi}, {0, phi, -1/phi}, {0, -phi, 1/phi}, {0, -phi, -1/phi},
    {1/phi, 0, phi}, {-1/phi, 0, phi}, {1/phi, 0, -phi}, {-1/phi, 0, -phi},
    {phi, 1/phi, 0}, {phi, -1/phi, 0}, {-phi, 1/phi, 0}, {-phi, -1/phi, 0}
  },
  edges = {
    {1, 9}, {1, 13}, {1, 17}, {2, 10}, {2, 15}, {2, 17},
    {3, 11}, {3, 13}, {3, 18}, {4, 12}, {4, 15}, {4, 18},
    {5, 9}, {5, 14}, {5, 19}, {6, 10}, {6, 16}, {6, 19},
    {7, 11}, {7, 14}, {7, 20}, {8, 12}, {8, 16}, {8, 20},
    {9, 10}, {11, 12}, {13, 14}, {15, 16}, {17, 18}, {19, 20}
  }
}

shapes[2] = {
  name = "Icosahedron",
  vertices = {
    {0, 1, phi}, {0, 1, -phi}, {0, -1, phi}, {0, -1, -phi},
    {1, phi, 0}, {1, -phi, 0}, {-1, phi, 0}, {-1, -phi, 0},
    {phi, 0, 1}, {phi, 0, -1}, {-phi, 0, 1}, {-phi, 0, -1}
  },
  edges = {
    {1, 3}, {1, 5}, {1, 7}, {1, 9}, {1, 11},
    {2, 4}, {2, 5}, {2, 7}, {2, 10}, {2, 12},
    {3, 6}, {3, 8}, {3, 9}, {3, 11}, {4, 6},
    {4, 8}, {4, 10}, {4, 12}, {5, 7}, {5, 9},
    {5, 10}, {6, 8}, {6, 9}, {6, 10}, {7, 11},
    {7, 12}, {8, 11}, {8, 12}, {9, 10}, {11, 12}
  }
}

shapes[3] = {
  name = "Octahedron",
  vertices = {
    {1, 0, 0}, {-1, 0, 0}, {0, 1, 0}, 
    {0, -1, 0}, {0, 0, 1}, {0, 0, -1}
  },
  edges = {
    {1, 3}, {1, 4}, {1, 5}, {1, 6},
    {2, 3}, {2, 4}, {2, 5}, {2, 6},
    {3, 5}, {3, 6}, {4, 5}, {4, 6}
  }
}

shapes[4] = {
  name = "Tetrahedron",
  vertices = {
    {1, 1, 1}, {1, -1, -1}, {-1, 1, -1}, {-1, -1, 1}
  },
  edges = {
    {1, 2}, {1, 3}, {1, 4}, {2, 3}, {2, 4}, {3, 4}
  }
}

shapes[5] = {
  name = "Cube",
  vertices = {
    {1, 1, 1}, {1, 1, -1}, {1, -1, 1}, {1, -1, -1},
    {-1, 1, 1}, {-1, 1, -1}, {-1, -1, 1}, {-1, -1, -1}
  },
  edges = {
    {1, 2}, {1, 3}, {1, 5}, {2, 4}, {2, 6},
    {3, 4}, {3, 7}, {4, 8}, {5, 6}, {5, 7},
    {6, 8}, {7, 8}
  }
}

local stars = {}
local star_offset_x = 0
local star_offset_y = 0

function init_planets()
  planets = {}
  local count = get_param_value(39, 3)
  for i = 1, count do
    planets[i] = {
      x = math.random(256) - 64,
      y = math.random(128) - 32,
      z = math.random() * 2 + 0.5,
      size = math.random(2, 6),
      type = math.random(3), 
      orbit_speed = (math.random() - 0.5) * 0.02,
      orbit_radius = math.random(20, 60),
      orbit_angle = math.random() * math.pi * 2,
      rings = math.random() < 0.3, 
      brightness = math.random(8, 12)
    }
  end
end

function init_meteors()
  meteors = {}
  local count = get_param_value(40, 5)
  for i = 1, count do
    meteors[i] = {
      x = math.random(256) - 64,
      y = math.random(128) - 32,
      vx = (math.random() - 0.5) * 2,
      vy = (math.random() - 0.5) * 1.5,
      size = math.random() * 2 + 0.5,
      trail_length = math.random(3, 8),
      trail = {},
      brightness = math.random(10, 15)
    }
  end
end

function note_to_hz(note)
  return 440 * 2^((note - 69) / 12)
end

function scale_note(degree, octave)
  if not current_scale or #current_scale == 0 then
    return root_note
  end
  local scale_degree = ((degree - 1) % #current_scale) + 1
  local oct_offset = math.floor((degree - 1) / #current_scale)
  return root_note + current_scale[scale_degree] + (octave + oct_offset) * 12
end

function build_chord(root_degree, chord_type, octave, inversion)
  local notes = {}
  local root = scale_note(root_degree, octave)
  
  if chord_type == "maj" then
    notes = {root, root + 4, root + 7}
  elseif chord_type == "min" then
    notes = {root, root + 3, root + 7}
  elseif chord_type == "maj7" then
    notes = {root, root + 4, root + 7, root + 11}
  elseif chord_type == "min7" then
    notes = {root, root + 3, root + 7, root + 10}
  elseif chord_type == "sus4" then
    notes = {root, root + 5, root + 7}
  elseif chord_type == "sus2" then
    notes = {root, root + 2, root + 7}
  elseif chord_type == "7sus4" then
    notes = {root, root + 5, root + 7, root + 10}
  elseif chord_type == "dim" then
    notes = {root, root + 3, root + 6}
  elseif chord_type == "dim7" then
    notes = {root, root + 3, root + 6, root + 9}
  elseif chord_type == "min7b5" then
    notes = {root, root + 3, root + 6, root + 10}
  elseif chord_type == "7" then
    notes = {root, root + 4, root + 7, root + 10}
  elseif chord_type == "7alt" then
    notes = {root, root + 4, root + 6, root + 10}
  elseif chord_type == "maj9" then
    notes = {root, root + 4, root + 7, root + 11, root + 14}
  elseif chord_type == "min9" then
    notes = {root, root + 3, root + 7, root + 10, root + 14}
  elseif chord_type == "maj7#11" then
    notes = {root, root + 4, root + 7, root + 11, root + 18}
  elseif chord_type == "min11" then
    notes = {root, root + 3, root + 7, root + 10, root + 17}
  elseif chord_type == "min6" then
    notes = {root, root + 3, root + 7, root + 9}
  elseif chord_type == "min/7" then
    notes = {root - 2, root, root + 3, root + 7}
  elseif chord_type == "min/6" then
    notes = {root - 4, root, root + 3, root + 7}
  elseif chord_type == "min/5" then
    notes = {root - 5, root, root + 3, root + 7}
  else
    notes = {root, root + 4, root + 7}
  end
  
  if inversion and inversion > 0 then
    for i = 1, inversion do
      if #notes > 0 then
        local first = table.remove(notes, 1)
        table.insert(notes, first + 12)
      end
    end
  end
  
  return notes
end

function voice_lead_chord(new_chord, previous_chord)
  if not previous_chord or #previous_chord == 0 or not voice_leading_active then
    return new_chord
  end
  
  local led_chord = {}
  for i, new_note in ipairs(new_chord) do
    if previous_chord[i] then
      local prev_note = previous_chord[i]
      local best_note = new_note
      local min_distance = math.abs(new_note - prev_note)
      
      for oct = -2, 2 do
        local test_note = new_note + (oct * 12)
        local distance = math.abs(test_note - prev_note)
        if distance < min_distance then
          min_distance = distance
          best_note = test_note
        end
      end
      
      led_chord[i] = best_note
    else
      led_chord[i] = new_note
    end
  end
  
  return led_chord
end

function update_scale()
  local scale_type = math.floor(get_param_value(24, 1))
  local scale_list = {
    "major", 
    "minor",
    "harmonic_minor", 
    "melodic_minor",
    "dorian", 
    "phrygian",
    "mixolydian", 
    "aeolian", 
    "lydian", 
    "pentatonic",
    "minor_pentatonic",
    "suspended"
  }
  current_scale = scales[scale_list[scale_type]] or scales.major
end

function generate_melody_pattern()
  melody_sequence = {}
  bass_sequence = {}
  arp_sequence = {}
  pad_sequence = {}
  
  phrase_length = math.floor(get_param_value(27, 64))
  root_note = math.floor(get_param_value(25, 60))
  harmonic_rhythm = math.floor(get_param_value(33, 16))
  voice_leading_active = get_param_value(38, 1) > 0
  update_scale()
  
  local prog_type_names = {"peaceful", "nostalgic", "mysterious", "adventurous", "melancholic", "dark", "epic", "ethereal", "cinematic"}
  current_progression_type = prog_type_names[math.floor(get_param_value(26, 1))]
  current_progression = minecraft_progressions[current_progression_type] or minecraft_progressions.peaceful
  
  current_chord_index = 1
  next_chord_change = 1
  
  local chord_data = current_progression[1]
  if chord_data then
    current_chord_notes = build_chord(chord_data[1], chord_data[2], 0, chord_data.inv)
  else
    current_chord_notes = {60, 64, 67}
  end
  previous_chord_notes = {}
  
  melody_variation_counter = 0
  bass_variation_counter = 0
  current_melody_pattern = math.random(#melody_patterns)
  current_bass_pattern = math.random(#bass_patterns)
  
  local arp_keys = {}
  for k, _ in pairs(minecraft_arp_patterns) do
    table.insert(arp_keys, k)
  end
  current_arp_pattern = arp_keys[math.random(#arp_keys)] or "gentle"
end

function music_tick()
  if not music_playing then return end
  
  local step = ((current_step - 1) % phrase_length) + 1
  
  if step >= next_chord_change then
    current_chord_index = (current_chord_index % #current_progression) + 1
    local chord_data = current_progression[current_chord_index]
    
    if chord_data then
      previous_chord_notes = current_chord_notes
      
      local new_chord = build_chord(chord_data[1], chord_data[2], 0, chord_data.inv)
      current_chord_notes = voice_lead_chord(new_chord, previous_chord_notes)
    end
    
    next_chord_change = next_chord_change + harmonic_rhythm
    
    local pad_pattern = pad_patterns[math.random(#pad_patterns)]
    local pad_density = get_param_value(35, 0.5)
    
    if pad_pattern and math.random() < pad_density * pad_pattern.prob then
      local notes_to_play = {}
      if pad_pattern.notes == "all" then
        notes_to_play = current_chord_notes
      else
        for _, idx in ipairs(pad_pattern.notes) do
          if idx <= #current_chord_notes then
            table.insert(notes_to_play, current_chord_notes[idx])
          end
        end
      end
      
      local pad_volume = get_param_value(34, 0.2)
      for i, note in ipairs(notes_to_play) do
        if note then
          engine.amp(pad_volume * 0.15)
          engine.hz(note_to_hz(note - 12))
          engine.pw(0.7 + math.random() * 0.2)
          engine.release(pad_pattern.duration * 0.2)
          engine.cutoff(400 + i * 100 + math.random(200))
        end
      end
    end
    
    local evolution = get_param_value(32, 0.3)
    if math.random() < evolution * 0.3 then
      current_melody_pattern = math.random(#melody_patterns)
      melody_variation_counter = melody_variation_counter + 1
    end
    
    local bass_variation = get_param_value(37, 0.5)
    if math.random() < bass_variation * 0.4 then
      current_bass_pattern = math.random(#bass_patterns)
      bass_variation_counter = bass_variation_counter + 1
    end
  end
  
  local melody_pattern = melody_patterns[current_melody_pattern]
  local melody_density = get_param_value(36, 0.5)
  
  if melody_pattern and melody_pattern.timing and melody_pattern.notes then
    for i, timing in ipairs(melody_pattern.timing) do
      if step % 32 == timing and math.random() < melody_pattern.prob * melody_density then
        local note_degree = melody_pattern.notes[i]
        if note_degree and note_degree <= #current_chord_notes and current_chord_notes[note_degree] then
          local note = current_chord_notes[note_degree] + melody_pattern.octave * 12
          
          if melody_pattern.passing and i > 1 and math.random() < 0.3 then
            local prev_degree = melody_pattern.notes[i-1]
            if prev_degree and prev_degree <= #current_chord_notes and current_chord_notes[prev_degree] then
              local prev_note = current_chord_notes[prev_degree] + melody_pattern.octave * 12
              local passing_note = (note + prev_note) / 2
              local melody_volume = get_param_value(29, 0.4)
              engine.amp(melody_volume * 0.2)
              engine.hz(note_to_hz(passing_note))
              engine.pw(0.15)
              engine.release(0.5)
              engine.cutoff(600)
            end
          end
          
          if melody_pattern.ornament and math.random() < 0.2 then
            local melody_volume = get_param_value(29, 0.4)
            engine.amp(melody_volume * 0.3)
            engine.hz(note_to_hz(note + 2))
            engine.pw(0.1)
            engine.release(0.2)
            engine.cutoff(1000)
          end
          
          local melody_volume = get_param_value(29, 0.4)
          engine.amp(melody_volume * 0.4)
          engine.hz(note_to_hz(note))
          engine.pw(0.2 + math.random() * 0.1)
          engine.release(2.0 + math.random())
          engine.cutoff(800 + math.random(400))
        end
      end
    end
  end
  
  local bass_pattern = bass_patterns[current_bass_pattern]
  if bass_pattern and bass_pattern.timing and bass_pattern.notes then
    for i, timing in ipairs(bass_pattern.timing) do
      if step % 16 == timing and math.random() < bass_pattern.prob then
        local note_degree = bass_pattern.notes[i]
        local octave
        
        if bass_pattern.octaves then
          octave = bass_pattern.octaves[i] or bass_pattern.octaves[1]
        else
          octave = bass_pattern.octave
        end
        
        local note
        if note_degree and note_degree <= #current_chord_notes and current_chord_notes[note_degree] then
          note = current_chord_notes[note_degree] + octave * 12
        else
          note = current_chord_notes[1] + octave * 12
        end
        
        if bass_pattern.walking and i > 1 and math.random() < 0.4 then
          local prev_degree = bass_pattern.notes[i-1] or 1
          if prev_degree <= #current_chord_notes and current_chord_notes[prev_degree] then
            local prev_note = current_chord_notes[prev_degree] + octave * 12
            if math.abs(note - prev_note) > 2 then
              local chromatic_note = prev_note + (note > prev_note and 1 or -1)
              local bass_volume = get_param_value(30, 0.3)
              engine.amp(bass_volume * 0.3)
              engine.hz(note_to_hz(chromatic_note))
              engine.pw(0.9)
              engine.release(0.5)
              engine.cutoff(150)
            end
          end
        end
        
        local amp_variation = 1.0
        if timing % 4 ~= 1 then
          amp_variation = 0.7 + math.random() * 0.2
        end
        
        local bass_volume = get_param_value(30, 0.3)
        engine.amp(bass_volume * 0.5 * amp_variation)
        engine.hz(note_to_hz(note))
        engine.pw(0.8 + math.random() * 0.1)
        engine.release(1.5 + math.random() * 0.5)
        engine.cutoff(200 + math.random(150))
      end
    end
  end
  
  local arp_pattern = minecraft_arp_patterns[current_arp_pattern]
  local arp_timing = {1, 3, 5, 7, 9, 11, 13, 15}
  
  if arp_pattern then
    for i, timing in ipairs(arp_timing) do
      if step % 16 == timing then
        local note_index = ((i - 1) % #arp_pattern) + 1
        local arp_note_degree = arp_pattern[note_index]
        if arp_note_degree and arp_note_degree <= #current_chord_notes and current_chord_notes[arp_note_degree] then
          local note = current_chord_notes[arp_note_degree]
          
          local octave_shift = 0
          if math.random() < 0.3 then
            octave_shift = math.random(2) == 1 and 12 or -12
          end
          
          if math.random() < 0.2 then
            clock.run(function()
              clock.sleep(0.05)
              local arp_volume = get_param_value(31, 0.3)
              engine.amp(arp_volume * 0.15)
              engine.hz(note_to_hz(note + octave_shift + 12))
              engine.pw(0.05)
              engine.release(0.5)
              engine.cutoff(1500)
            end)
          end
          
          local arp_volume = get_param_value(31, 0.3)
          engine.amp(arp_volume * 0.3)
          engine.hz(note_to_hz(note + octave_shift))
          engine.pw(0.1 + math.random() * 0.05)
          engine.release(1.0 + math.random() * 0.5)
          engine.cutoff(1200 + math.random(600))
        end
      end
    end
  end
  
  current_step = current_step + 1
  
  if current_step > phrase_length then
    current_step = 1
    next_chord_change = 1
    current_chord_index = 0
    
    if math.random() < 0.4 then
      local arp_keys = {}
      for k, _ in pairs(minecraft_arp_patterns) do
        table.insert(arp_keys, k)
      end
      current_arp_pattern = arp_keys[math.random(#arp_keys)] or "gentle"
    end
  end
  
  last_note_time = util.time()
end

function init_stars()
  stars = {}
  local count = get_param_value(10, 50)
  for i = 1, count do
    stars[i] = {
      x = math.random(256) - 64,
      y = math.random(128) - 32,
      z = math.random() * 3,
      brightness = math.random(3, 15),
      twinkle = math.random() * math.pi * 2
    }
  end
end

function create_annotation()
  local shape = shapes[current_shape]
  if not shape then return nil end
  
  local target_type = math.random(2)
  local target_index
  
  if target_type == 1 then
    target_index = math.random(#shape.vertices)
  else
    target_index = math.random(#shape.edges)
  end
  
  local text = system_logs[math.random(#system_logs)]
  local text_width = 20
  
  local quadrants = {
    {5, 5, 40, 25},
    {88, 5, 123, 25},
    {5, 39, 40, 59},
    {88, 39, 123, 59}
  }
  
  local quad = quadrants[math.random(#quadrants)]
  local box_x = math.random(quad[1], quad[3])
  local box_y = math.random(quad[2], quad[4])
  
  box_x = util.clamp(box_x, text_width/2 + 2, 126 - text_width/2)
  box_y = util.clamp(box_y, 7, 57)
  
  annotation_counter = annotation_counter + 1
  
  return {
    text = text,
    text_width = text_width,
    box_x = box_x,
    box_y = box_y,
    target_type = target_type,
    target_index = target_index,
    life = 120,
    alpha = 0,
    id = annotation_counter
  }
end

function get_time_string()
  local time_format = get_param_value(21, 1)
  local time = os.date(time_format == 1 and "%H:%M" or "%I:%M %p")
  return time
end

function init()
  init_stars()
  init_planets()
  init_meteors()
  
  clock.tempo = 50
  
  music_playing = get_param_value(22, 1) > 0
  auto_zoom_active = get_param_value(41, 1) > 0
  base_zoom = get_param_value(2, 90)
  
  if engine.name == "PolyPerc" then
    engine.release(0.5)
    engine.pw(0.5)
    engine.cutoff(2000)
    engine.gain(1)
  end
  
  update_scale()
  generate_melody_pattern()
  
  sequence_clock = clock.run(function()
    while true do
      if music_playing then
        music_tick()
      end
      clock.sync(1/4)
    end
  end)
  
  redraw_timer = metro.init()
  redraw_timer.time = 1/60
  redraw_timer.event = function()
    if get_param_value(6, 1) > 0 then
      angle_x = angle_x + auto_speed_x * get_param_value(7, 1) * 0.01
      angle_y = angle_y + auto_speed_y * get_param_value(8, 1) * 0.01
      angle_z = angle_z + auto_speed_z * get_param_value(9, 1) * 0.01
      
      params_list[3].value = math.deg(angle_x) % 360 - 180
      params_list[4].value = math.deg(angle_y) % 360 - 180
      params_list[5].value = math.deg(angle_z) % 360 - 180
      
      local total_speed = math.abs(get_param_value(7, 1)) + math.abs(get_param_value(8, 1)) + math.abs(get_param_value(9, 1))
      local annotation_freq = get_param_value(17, 0.5)
      local max_annotations = get_param_value(18, 5)
      
      if total_speed > 0.5 and annotation_freq > 0 and math.random() < total_speed * annotation_freq * 0.005 and #active_annotations < max_annotations then
        local new_annotation = create_annotation()
        if new_annotation then
          table.insert(active_annotations, new_annotation)
        end
      end
    end
    
    auto_zoom_active = get_param_value(41, 1) > 0
    if auto_zoom_active then
      auto_zoom_speed = get_param_value(43, 0.02)
      auto_zoom_phase = auto_zoom_phase + auto_zoom_speed
      local zoom_range = get_param_value(42, 30)
      local zoom_offset = math.sin(auto_zoom_phase) * zoom_range
      params_list[2].value = util.clamp(base_zoom + zoom_offset, 5, 100)
    end
    
    radiation_angle = radiation_angle + 0.05
    radiation_alpha = radiation_alpha + 0.02 * radiation_alpha_direction
    if radiation_alpha > 0.9 then
      radiation_alpha = 0.9
      radiation_alpha_direction = -1
    elseif radiation_alpha < 0.2 then
      radiation_alpha = 0.2
      radiation_alpha_direction = 1
    end
    
    for _, planet in ipairs(planets) do
      planet.orbit_angle = planet.orbit_angle + planet.orbit_speed
    end
    
    for _, meteor in ipairs(meteors) do
      table.insert(meteor.trail, 1, {x = meteor.x, y = meteor.y})
      if #meteor.trail > meteor.trail_length then
        table.remove(meteor.trail)
      end
      
      meteor.x = meteor.x + meteor.vx
      meteor.y = meteor.y + meteor.vy
      
      if meteor.x < -100 or meteor.x > 228 or meteor.y < -50 or meteor.y > 114 then
        meteor.x = math.random(2) == 1 and -50 or 178
        meteor.y = math.random(128) - 32
        meteor.vx = (math.random() - 0.5) * 2
        meteor.vy = (math.random() - 0.5) * 1.5
        meteor.trail = {}
      end
    end
    
    for i = #active_annotations, 1, -1 do
      local ann = active_annotations[i]
      ann.life = ann.life - 1
      
      if ann.life > 100 then
        ann.alpha = math.min(ann.alpha + 0.1, 1)
      elseif ann.life < 20 then
        ann.alpha = math.max(ann.alpha - 0.05, 0)
      end
      
      if ann.life <= 0 then
        table.remove(active_annotations, i)
      end
    end
    
    redraw()
  end
  redraw_timer:start()
end

function rotate_3d(point, ax, ay, az)
  local x, y, z = point[1], point[2], point[3]
  
  local cos_x, sin_x = math.cos(ax), math.sin(ax)
  y, z = y * cos_x - z * sin_x, y * sin_x + z * cos_x
  
  local cos_y, sin_y = math.cos(ay), math.sin(ay)
  x, z = x * cos_y + z * sin_y, -x * sin_y + z * cos_y
  
  local cos_z, sin_z = math.cos(az), math.sin(az)
  x, y = x * cos_z - y * sin_z, x * sin_z + y * cos_z
  
  return {x, y, z}
end

function project(point)
  local perspective = get_param_value(13, 5)
  local zoom = get_param_value(2, 90)
  local scale = zoom / (perspective + point[3])
  return {
    64 + point[1] * scale,
    32 + point[2] * scale
  }
end

function draw_radiation_icon(x, y, size, angle, alpha)
  screen.level(math.floor(15 * alpha))
  
  for i = 0, 2 do
    local a = angle + (i * math.pi * 2 / 3)
    local x1 = x + math.cos(a) * size * 0.3
    local y1 = y + math.sin(a) * size * 0.3
    local x2 = x + math.cos(a - 0.3) * size
    local y2 = y + math.sin(a - 0.3) * size
    local x3 = x + math.cos(a + 0.3) * size
    local y3 = y + math.sin(a + 0.3) * size
    
    screen.move(x1, y1)
    screen.line(x2, y2)
    screen.line(x3, y3)
    screen.close()
    screen.fill()
  end
  
  screen.circle(x, y, size * 0.2)
  screen.fill()
end

function draw_background()
  if get_param_value(16, 0) > 0 then
    for y = 0, 64, 2 do
      local level = math.floor(y / 64 * 5)
      screen.level(level)
      screen.rect(0, y, 128, 2)
      screen.fill()
    end
  end
  
  local star_speed = get_param_value(11, 1)
  local parallax = get_param_value(12, 1)
  
  for i, star in ipairs(stars) do
    star.twinkle = star.twinkle + 0.05 * star_speed
    local brightness = star.brightness * (0.5 + 0.5 * math.sin(star.twinkle))
    screen.level(math.floor(brightness))
    
    local parallax_factor = 1 + (star.z - 1.5) * parallax * 0.3
    local x = star.x - star_offset_x * parallax_factor
    local y = star.y - star_offset_y * parallax_factor
    
    x = ((x + 64) % 256) - 64
    y = ((y + 32) % 128) - 32
    
    if x >= 0 and x < 128 and y >= 0 and y < 64 then
      screen.pixel(x, y)
      screen.fill()
    end
  end
  
  for _, planet in ipairs(planets) do
    local px = planet.x + math.cos(planet.orbit_angle) * planet.orbit_radius
    local py = planet.y + math.sin(planet.orbit_angle) * planet.orbit_radius * 0.5
    
    local parallax_factor = 1 + (planet.z - 1.5) * parallax * 0.2
    px = px - star_offset_x * parallax_factor * 0.5
    py = py - star_offset_y * parallax_factor * 0.5
    
    if px >= -10 and px < 138 and py >= -10 and py < 74 then
      screen.level(planet.brightness)
      
      if planet.type == 1 then 
        screen.circle(px, py, planet.size)
        screen.stroke()
        screen.circle(px, py, planet.size - 1)
        screen.stroke()
      elseif planet.type == 2 then 
        screen.circle(px, py, planet.size)
        screen.fill()
        screen.level(math.max(1, planet.brightness - 5))
        screen.pixel(px - planet.size/3, py - planet.size/3)
        screen.fill()
      else 
        screen.circle(px, py, planet.size)
        screen.stroke()
        screen.level(math.min(15, planet.brightness + 3))
        screen.pixel(px + planet.size/3, py - planet.size/3)
        screen.fill()
      end
      
      if planet.rings then
        screen.level(planet.brightness - 3)
        for r = planet.size + 2, planet.size + 4, 0.5 do
          screen.arc(px, py, r, r * 0.3, math.pi * 0.2, math.pi * 1.8)
          screen.stroke()
        end
      end
    end
  end
  
  for _, meteor in ipairs(meteors) do
    if meteor.x >= -10 and meteor.x < 138 and meteor.y >= -10 and meteor.y < 74 then
      for i, pos in ipairs(meteor.trail) do
        local alpha = (1 - i / #meteor.trail)
        screen.level(math.floor(meteor.brightness * alpha * 0.5))
        screen.pixel(pos.x, pos.y)
        screen.fill()
      end
      screen.level(meteor.brightness)
      screen.circle(meteor.x, meteor.y, meteor.size)
      screen.fill()
    end
  end
end

function draw_clipped_line(x1, y1, x2, y2, width)
  if width == 1 then
    screen.move(x1, y1)
    screen.line(x2, y2)
    screen.stroke()
  else
    for w = -width/2, width/2, 0.5 do
      screen.move(x1, y1 + w)
      screen.line(x2, y2 + w)
      screen.stroke()
    end
  end
end

function draw_annotation(ann, transformed, projected)
  local shape = shapes[current_shape]
  if not shape then return end
  
  local target_x, target_y
  
  if ann.target_type == 1 then
    if projected[ann.target_index] then
      target_x = projected[ann.target_index][1]
      target_y = projected[ann.target_index][2]
    else
      return
    end
  else
    local edge = shape.edges[ann.target_index]
    if edge and projected[edge[1]] and projected[edge[2]] then
      target_x = (projected[edge[1]][1] + projected[edge[2]][1]) / 2
      target_y = (projected[edge[1]][2] + projected[edge[2]][2]) / 2
    else
      return
    end
  end
  
  local brightness = math.floor(15 * ann.alpha)
  
  screen.level(brightness)
  screen.rect(ann.box_x - ann.text_width/2 + 1, ann.box_y - 5, ann.text_width - 2, 10)
  screen.stroke()
  
  screen.pixel(ann.box_x - ann.text_width/2, ann.box_y - 4)
  screen.pixel(ann.box_x - ann.text_width/2, ann.box_y + 4)
  screen.pixel(ann.box_x + ann.text_width/2, ann.box_y - 4)
  screen.pixel(ann.box_x + ann.text_width/2, ann.box_y + 4)
  screen.fill()
  
  screen.move(ann.box_x, ann.box_y + 2)
  screen.text_center(string.lower(ann.text))
  
  screen.level(math.floor(brightness * 0.5))
  
  local box_left = ann.box_x - ann.text_width/2
  local box_right = ann.box_x + ann.text_width/2
  local box_top = ann.box_y - 5
  local box_bottom = ann.box_y + 5
  
  local line_start_x, line_start_y
  
  if target_x < box_left then
    line_start_x = box_left
    line_start_y = util.clamp(target_y, box_top, box_bottom)
  elseif target_x > box_right then
    line_start_x = box_right
    line_start_y = util.clamp(target_y, box_top, box_bottom)
  elseif target_y < box_top then
    line_start_x = util.clamp(target_x, box_left, box_right)
    line_start_y = box_top
  else
    line_start_x = util.clamp(target_x, box_left, box_right)
    line_start_y = box_bottom
  end
  
  local mid_x = line_start_x + (target_x - line_start_x) * 0.7
  local mid_y = line_start_y + (target_y - line_start_y) * 0.7
  
  screen.move(line_start_x, line_start_y)
  screen.line(mid_x, mid_y)
  screen.stroke()
  
  screen.level(brightness)
  screen.move(mid_x, mid_y)
  screen.line(target_x, target_y)
  screen.stroke()
  
  screen.rect(target_x - 1, target_y - 1, 3, 3)
  screen.fill()
end

function enc(n, d)
  if n == 1 then
    if menu_active then
      menu_index = util.clamp(menu_index + d, 1, #params_list)
    end
  elseif n == 2 then
    if menu_active then
      local param = params_list[menu_index]
      param.value = util.clamp(param.value + d * param.step, param.min, param.max)
      
      if param.id == "shape" then
        current_shape = math.floor(param.value)
        active_annotations = {}
      elseif param.id == "angle_x" then
        angle_x = math.rad(param.value)
      elseif param.id == "angle_y" then
        angle_y = math.rad(param.value)
      elseif param.id == "angle_z" then
        angle_z = math.rad(param.value)
      elseif param.id == "star_count" then
        init_stars()
      elseif param.id == "planet_count" then
        init_planets()
      elseif param.id == "meteor_count" then
        init_meteors()
      elseif param.id == "music_on" then
        music_playing = param.value > 0
        if not music_playing then
          current_step = 1
        end
      elseif param.id == "scale_type" then
        update_scale()
        generate_melody_pattern()
      elseif param.id == "root_note" then
        root_note = param.value
        generate_melody_pattern()
      elseif param.id == "progression_type" then
        generate_melody_pattern()
      elseif param.id == "phrase_length" then
        phrase_length = param.value
        generate_melody_pattern()
      elseif param.id == "harmonic_rhythm" then
        harmonic_rhythm = param.value
      elseif param.id == "voice_leading" then
        voice_leading_active = param.value > 0
      elseif param.id == "zoom" then
        base_zoom = param.value
      end
    else
      angle_y = angle_y + d * 0.05
      star_offset_x = star_offset_x - d * 2 * get_param_value(11, 1)
    end
  elseif n == 3 then
    if not menu_active then
      angle_x = angle_x + d * 0.05
      star_offset_y = star_offset_y - d * 2 * get_param_value(11, 1)
    end
  end
end

function key(n, z)
  if z == 1 then
    if n == 1 then
      menu_active = not menu_active
    elseif n == 2 then
      if menu_active then
        local param = params_list[menu_index]
        if param.id == "shape" then
          param.value = 1
          current_shape = 1
          active_annotations = {}
        elseif param.id == "zoom" then
          param.value = 90
          base_zoom = 90
        elseif param.id:match("angle") then
          param.value = 0
          if param.id == "angle_x" then angle_x = 0
          elseif param.id == "angle_y" then angle_y = 0
          elseif param.id == "angle_z" then angle_z = 0
          end
        elseif param.id:match("speed") then
          param.value = 20
        elseif param.id == "generate_music" then
          generate_melody_pattern()
          current_step = 1
        end
      end
    elseif n == 3 then
      if not menu_active then
        params_list[6].value = get_param_value(6, 1) > 0 and 0 or 1
      end
    end
  end
end

function redraw()
  screen.clear()
  
  if menu_active then
    screen.level(15)
    screen.move(2, 8)
    screen.text("SYST")
    
    local start_index = math.max(1, menu_index - 3)
    local end_index = math.min(#params_list, start_index + 6)
    
    for i = start_index, end_index do
      local y = 16 + (i - start_index) * 8
      local param = params_list[i]
      
      if i == menu_index then
        screen.level(15)
        screen.rect(0, y - 6, 128, 8)
        screen.fill()
        screen.level(0)
      else
        screen.level(10)
      end
      
      screen.move(2, y)
      screen.text(param.name)
      
      screen.move(126, y)
      screen.text_right(param.formatter and param.formatter(param.value) or string.format("%.1f", param.value))
    end
  else
    if get_param_value(6, 1) > 0 then
      star_offset_x = star_offset_x + get_param_value(8, 1) * get_param_value(11, 1) * 0.2
      star_offset_y = star_offset_y + get_param_value(7, 1) * get_param_value(11, 1) * 0.2
    end
    
    draw_background()
    
    local shape = shapes[current_shape]
    if not shape then return end
    
    local transformed = {}
    for i, v in ipairs(shape.vertices) do
      transformed[i] = rotate_3d(v, angle_x, angle_y, angle_z)
    end
    
    local projected = {}
    for i, v in ipairs(transformed) do
      projected[i] = project(v)
    end
    
    local sorted_edges = {}
    for _, edge in ipairs(shape.edges) do
      local z_avg = (transformed[edge[1]][3] + transformed[edge[2]][3]) / 2
      table.insert(sorted_edges, {edge = edge, z = z_avg})
    end
    table.sort(sorted_edges, function(a, b) return a.z < b.z end)
    
    local line_width = get_param_value(14, 1)
    for _, edge_data in ipairs(sorted_edges) do
      local edge = edge_data.edge
      local z = edge_data.z
      
      local brightness = math.floor(15 - (z + 3) * 2)
      brightness = util.clamp(brightness, 5, 15)
      
      if music_playing and (util.time() - last_note_time) < 0.15 then
        brightness = math.min(brightness + 2, 15)
      end
      
      screen.level(brightness)
      
      draw_clipped_line(
        projected[edge[1]][1], projected[edge[1]][2],
        projected[edge[2]][1], projected[edge[2]][2],
        line_width
      )
    end
    
    local vertex_size = get_param_value(15, 1)
    if vertex_size > 0 then
      screen.level(15)
      for i, p in ipairs(projected) do
        if transformed[i][3] > -2 then
          local size = vertex_size
          if music_playing and (util.time() - last_note_time) < 0.15 then
            size = size * 1.3
          end
          screen.circle(p[1], p[2], size)
          screen.fill()
        end
      end
    end
    
    for _, ann in ipairs(active_annotations) do
      draw_annotation(ann, transformed, projected)
    end
    
    draw_radiation_icon(118, 10, 6, radiation_angle, radiation_alpha)
    
    if get_param_value(6, 1) > 0 then
      screen.level(10)
      screen.move(2, 62)
      screen.text("A")
    end
    
    if get_param_value(20, 1) > 0 then
      screen.level(8)
      screen.move(126, 62)
      screen.text_right(get_time_string())
    end
  end
  
  screen.update()
end

function cleanup()
  redraw_timer:stop()
  if sequence_clock then
    clock.cancel(sequence_clock)
  end
end