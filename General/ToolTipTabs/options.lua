ToolTipTabs.options = {
	type = "group",	
	childGroups = "tab",
	args = {
		show = {
			type = "execute",
			name = "Show tooltips",
			guiHidden = true,
			func = function()
				ToolTipTabs:ShowAll()
			end,
		},
		desc = {
			type = "description",
			name = "ToolTipTabs adds tabbed and multi tooltip functionality to the default UI\n",
			order = 1,
			fontSize = "medium",
		},
		enable = {
			type = "toggle",
			name = "Enable",
			order = 2,
			desc = "Enable/Disable this addon",
			set = function(info, v) ToolTipTabs.db.profile.enable = v if v == true then ToolTipTabs:OnEnable() elseif v == false then ToolTipTabs:OnDisable() end end,
			get = function(info) return ToolTipTabs.db.profile.enable end,
		},
		appearance = {
			type = "group",
			name = "Appearance",
			order = 3,
			disabled = function()
				return not ToolTipTabs.db.profile.enable
			end,
			args = {
				scale = {
					type = "range",
					name = "Tab scale",
					order = 1,
					min = 0.1,
					max = 2,
					step = 0.01,
					isPercent = true,
					set = function(info, v)
						if v > 2 then v = 2 end
						if v < 0.1 then v = 0.1 end
						ToolTipTabs.db.profile.scale = v
						ToolTipTabs:TabScale()
					end,
					get = function(info)
						return ToolTipTabs.db.profile.scale
					end,
				},		
				format1 = {
					type = "description",
					name = "\n\nBorder Colors (Requires ButtonFacade)",
					order = 2,
					fontSize = "medium",
					width = "full",
				},
				item = {
					type = "group",
					name = "Item",
					order = 3,
					disabled = function() 
						if ToolTipTabs.LBF then 
							return false 
						else 
							return true 
						end
					end,
					args = {
						p = {
							type = "toggle",
							name = "Rarity Color",
							order = 1,
							get = function()
								return ToolTipTabs.db.profile.colors.item.preset
							end,
							set = function(i, v)
								if v == true then
									if ToolTipTabs.db.profile.colors.item.bf == true then
										ToolTipTabs.db.profile.colors.item.bf = false
									end
								end
								ToolTipTabs.db.profile.colors.item.preset = v
								ToolTipTabs:RecolorAll()								
							end,
						},
						b = {
							type = "toggle",
							name = "ButtonFacade Coloring",
							order = 2,
							get = function()
								return ToolTipTabs.db.profile.colors.item.bf
							end,
							set = function(i, v)
								if v == true then
									if ToolTipTabs.db.profile.colors.item.preset == true then
										ToolTipTabs.db.profile.colors.item.preset = false
									end
								end
								ToolTipTabs.db.profile.colors.item.bf = v
								ToolTipTabs:RecolorAll()								
							end,
						},
						c = {
							type = "color",
							name = "Custom Color",
							order = 3,
							get = function()
								return ToolTipTabs.db.profile.colors.item.r,ToolTipTabs.db.profile.colors.item.g,ToolTipTabs.db.profile.colors.item.b
							end,
							set = function(i, r, g, b)
								ToolTipTabs.db.profile.colors.item.r = r
								ToolTipTabs.db.profile.colors.item.g = g
								ToolTipTabs.db.profile.colors.item.b = b
								ToolTipTabs:RecolorAll()								
							end,							
							disabled = function()
								return ToolTipTabs.db.profile.colors.item.preset or ToolTipTabs.db.profile.colors.item.bf
							end,
						},
					},
				},
				spell = {
					type = "group",
					name = "Spell",
					order = 4,
					disabled = function() 
						if ToolTipTabs.LBF then 
							return false 
						else 
							return true 
						end
					end,
					args = {
						--[[p = {
							type = "toggle",
							name = "Rarity Color",
							order = 1,
							get = function()
								return ToolTipTabs.db.profile.colors.item.preset
							end,
							set = function(i, v)
								if v == true then
									if ToolTipTabs.db.profile.colors.item.bf == true then
										ToolTipTabs.db.profile.colors.item.bf = false
									end
								end
								ToolTipTabs.db.profile.colors.item.preset = v
								ToolTipTabs:RecolorAll()								
							end,
						},]]
						b = {
							type = "toggle",
							name = "ButtonFacade Coloring",
							order = 2,
							get = function()
								return ToolTipTabs.db.profile.colors.spell.bf
							end,
							set = function(i, v)
								if v == true then
									if ToolTipTabs.db.profile.colors.spell.preset == true then
										ToolTipTabs.db.profile.colors.spell.preset = false
									end
								end
								ToolTipTabs.db.profile.colors.spell.bf = v
								ToolTipTabs:RecolorAll()								
							end,
						},
						c = {
							type = "color",
							name = "Custom Color",
							order = 3,
							get = function()
								return ToolTipTabs.db.profile.colors.spell.r,ToolTipTabs.db.profile.colors.spell.g,ToolTipTabs.db.profile.colors.spell.b
							end,
							set = function(i, r, g, b)
								ToolTipTabs.db.profile.colors.spell.r = r
								ToolTipTabs.db.profile.colors.spell.g = g
								ToolTipTabs.db.profile.colors.spell.b = b
								ToolTipTabs:RecolorAll()								
							end,							
							disabled = function()
								return ToolTipTabs.db.profile.colors.spell.preset or ToolTipTabs.db.profile.colors.spell.bf
							end,
						},
					},
				},
				achievement = {
					type = "group",
					name = "Achievement",
					order = 5,
					disabled = function() 
						if ToolTipTabs.LBF then 
							return false 
						else 
							return true 
						end
					end,					
					args = {
						p = {
							type = "toggle",
							name = "Completion Color",
							order = 1,
							get = function()
								return ToolTipTabs.db.profile.colors.achievement.preset
							end,
							set = function(i, v)
								if v == true then
									if ToolTipTabs.db.profile.colors.achievement.bf == true then
										ToolTipTabs.db.profile.colors.achievement.bf = false
									end
								end
								ToolTipTabs.db.profile.colors.achievement.preset = v
								ToolTipTabs:RecolorAll()								
							end,
						},
						b = {
							type = "toggle",
							name = "ButtonFacade Coloring",
							order = 2,
							get = function()
								return ToolTipTabs.db.profile.colors.achievement.bf
							end,
							set = function(i, v)
								if v == true then
									if ToolTipTabs.db.profile.colors.achievement.preset == true then
										ToolTipTabs.db.profile.colors.achievement.preset = false
									end
								end
								ToolTipTabs.db.profile.colors.achievement.bf = v
								ToolTipTabs:RecolorAll()								
							end,
						},
						c = {
							type = "color",
							name = "Custom Color",
							order = 3,
							get = function()
								return ToolTipTabs.db.profile.colors.achievement.r,ToolTipTabs.db.profile.colors.achievement.g,ToolTipTabs.db.profile.colors.achievement.b
							end,
							set = function(i, r, g, b)
								ToolTipTabs.db.profile.colors.achievement.r = r
								ToolTipTabs.db.profile.colors.achievement.g = g
								ToolTipTabs.db.profile.colors.achievement.b = b
								ToolTipTabs:RecolorAll()								
							end,							
							disabled = function()
								return ToolTipTabs.db.profile.colors.achievement.preset or ToolTipTabs.db.profile.colors.achievement.bf
							end,
						},
					},
				},
				talent = {
					type = "group",
					name = "Talent",
					order = 6,
					disabled = function() 
						if ToolTipTabs.LBF then 
							return false 
						else 
							return true 
						end
					end,
					args = {
						--[[p = {
							type = "toggle",
							name = "Rarity Color",
							order = 1,
							get = function()
								return ToolTipTabs.db.profile.colors.item.preset
							end,
							set = function(i, v)
								if v == true then
									if ToolTipTabs.db.profile.colors.item.bf == true then
										ToolTipTabs.db.profile.colors.item.bf = false
									end
								end
								ToolTipTabs.db.profile.colors.item.preset = v
								ToolTipTabs:RecolorAll()								
							end,
						},]]
						b = {
							type = "toggle",
							name = "ButtonFacade Coloring",
							order = 2,
							get = function()
								return ToolTipTabs.db.profile.colors.talent.bf
							end,
							set = function(i, v)
								if v == true then
									if ToolTipTabs.db.profile.colors.talent.preset == true then
										ToolTipTabs.db.profile.colors.talent.preset = false
									end
								end
								ToolTipTabs.db.profile.colors.talent.bf = v
								ToolTipTabs:RecolorAll()								
							end,
						},
						c = {
							type = "color",
							name = "Custom Color",
							order = 3,
							get = function()
								return ToolTipTabs.db.profile.colors.talent.r,ToolTipTabs.db.profile.colors.talent.g,ToolTipTabs.db.profile.colors.talent.b
							end,
							set = function(i, r, g, b)
								ToolTipTabs.db.profile.colors.talent.r = r
								ToolTipTabs.db.profile.colors.talent.g = g
								ToolTipTabs.db.profile.colors.talent.b = b
								ToolTipTabs:RecolorAll()								
							end,							
							disabled = function()
								return ToolTipTabs.db.profile.colors.talent.preset or ToolTipTabs.db.profile.colors.talent.bf
							end,
						},
					},
				},
				quest = {
					type = "group",
					name = "Quest",
					order = 7,
					disabled = function() 
						if ToolTipTabs.LBF then 
							return false 
						else 
							return true 
						end
					end,					
					args = {
						p = {
							type = "toggle",
							name = "Difficulty Color",
							order = 1,
							get = function()
								return ToolTipTabs.db.profile.colors.quest.preset
							end,
							set = function(i, v)
								if v == true then
									if ToolTipTabs.db.profile.colors.quest.bf == true then
										ToolTipTabs.db.profile.colors.quest.bf = false
									end
								end
								ToolTipTabs.db.profile.colors.quest.preset = v
								ToolTipTabs:RecolorAll()								
							end,
						},
						b = {
							type = "toggle",
							name = "ButtonFacade Coloring",
							order = 2,
							get = function()
								return ToolTipTabs.db.profile.colors.quest.bf
							end,
							set = function(i, v)
								if v == true then
									if ToolTipTabs.db.profile.colors.quest.preset == true then
										ToolTipTabs.db.profile.colors.quest.preset = false
									end
								end
								ToolTipTabs.db.profile.colors.quest.bf = v
								ToolTipTabs:RecolorAll()								
							end,
						},
						c = {
							type = "color",
							name = "Custom Color",
							order = 3,
							get = function()
								return ToolTipTabs.db.profile.colors.quest.r,ToolTipTabs.db.profile.colors.quest.g,ToolTipTabs.db.profile.colors.quest.b
							end,
							set = function(i, r, g, b)
								ToolTipTabs.db.profile.colors.quest.r = r
								ToolTipTabs.db.profile.colors.quest.g = g
								ToolTipTabs.db.profile.colors.quest.b = b
								ToolTipTabs:RecolorAll()								
							end,							
							disabled = function()
								return ToolTipTabs.db.profile.colors.quest.preset or ToolTipTabs.db.profile.colors.quest.bf
							end,
						},
					},
				},
				enchant = {
					type = "group",
					name = "Enchant",
					order = 8,
					disabled = function() 
						if ToolTipTabs.LBF then 
							return false 
						else 
							return true 
						end
					end,
					args = {
						--[[p = {
							type = "toggle",
							name = "Rarity Color",
							order = 1,
							get = function()
								return ToolTipTabs.db.profile.colors.item.preset
							end,
							set = function(i, v)
								if v == true then
									if ToolTipTabs.db.profile.colors.item.bf == true then
										ToolTipTabs.db.profile.colors.item.bf = false
									end
								end
								ToolTipTabs.db.profile.colors.item.preset = v
								ToolTipTabs:RecolorAll()								
							end,
						},]]
						b = {
							type = "toggle",
							name = "ButtonFacade Coloring",
							order = 2,
							get = function()
								return ToolTipTabs.db.profile.colors.enchant.bf
							end,
							set = function(i, v)
								if v == true then
									if ToolTipTabs.db.profile.colors.enchant.preset == true then
										ToolTipTabs.db.profile.colors.enchant.preset = false
									end
								end
								ToolTipTabs.db.profile.colors.enchant.bf = v
								ToolTipTabs:RecolorAll()								
							end,
						},
						c = {
							type = "color",
							name = "Custom Color",
							order = 3,
							get = function()
								return ToolTipTabs.db.profile.colors.enchant.r,ToolTipTabs.db.profile.colors.enchant.g,ToolTipTabs.db.profile.colors.enchant.b
							end,
							set = function(i, r, g, b)
								ToolTipTabs.db.profile.colors.enchant.r = r
								ToolTipTabs.db.profile.colors.enchant.g = g
								ToolTipTabs.db.profile.colors.enchant.b = b
								ToolTipTabs:RecolorAll()								
							end,							
							disabled = function()
								return ToolTipTabs.db.profile.colors.enchant.preset or ToolTipTabs.db.profile.colors.enchant.bf
							end,
						},
					},				
				},
				glyph = {
					type = "group",
					name = "Glyph",
					order = 9,
					disabled = function() 
						if ToolTipTabs.LBF then 
							return false 
						else 
							return true 
						end
					end,
					args = {
						--[[p = {
							type = "toggle",
							name = "Rarity Color",
							order = 1,
							get = function()
								return ToolTipTabs.db.profile.colors.item.preset
							end,
							set = function(i, v)
								if v == true then
									if ToolTipTabs.db.profile.colors.item.bf == true then
										ToolTipTabs.db.profile.colors.item.bf = false
									end
								end
								ToolTipTabs.db.profile.colors.item.preset = v
								ToolTipTabs:RecolorAll()								
							end,
						},]]
						b = {
							type = "toggle",
							name = "ButtonFacade Coloring",
							order = 2,
							get = function()
								return ToolTipTabs.db.profile.colors.glyph.bf
							end,
							set = function(i, v)
								if v == true then
									if ToolTipTabs.db.profile.colors.glyph.preset == true then
										ToolTipTabs.db.profile.colors.glyph.preset = false
									end
								end
								ToolTipTabs.db.profile.colors.glyph.bf = v
								ToolTipTabs:RecolorAll()								
							end,
						},
						c = {
							type = "color",
							name = "Custom Color",
							order = 3,
							get = function()
								return ToolTipTabs.db.profile.colors.glyph.r,ToolTipTabs.db.profile.colors.glyph.g,ToolTipTabs.db.profile.colors.glyph.b
							end,
							set = function(i, r, g, b)
								ToolTipTabs.db.profile.colors.glyph.r = r
								ToolTipTabs.db.profile.colors.glyph.g = g
								ToolTipTabs.db.profile.colors.glyph.b = b
								ToolTipTabs:RecolorAll()								
							end,							
							disabled = function()
								return ToolTipTabs.db.profile.colors.glyph.preset or ToolTipTabs.db.profile.colors.glyph.bf
							end,
						},
					},				
				},
			},
		},
		positioning = {
			type = "group",
			name = "Positioning",
			order = 4,
			disabled = function()
				return not ToolTipTabs.db.profile.enable
			end,					
			args = {
				format1 = {
					type = "description",
					name = "The offset options allow you to alter the point on the tooltip where the tabs begin to form, by changing these values to be greater, the tabs will start further to the left and further down the side of the tooltip.\n",
					order = 1,
					fontSize = "medium",
				},
				xoffset = {
					type = "range",
					name = "X offset",
					order = 2,
					min = 0,
					max = 10,
					step = 1,
					set = function(info, v)
						if v > 10 then v = 10 end
						if v < 0 then v = 0 end
						ToolTipTabs.db.profile.xoffset = v
						ToolTipTabs:RedrawAll()
					end,
					get = function(info)
						return ToolTipTabs.db.profile.xoffset
					end,							
				},
				yoffset = {
					type = "range",
					name = "Y offset",
					order = 3,
					min = 0,
					max = 10,
					step = 1,
					set = function(info, v)
						if v > 10 then v = 10 end
						if v < 0 then v = 0 end
						ToolTipTabs.db.profile.yoffset = v
						ToolTipTabs:RedrawAll()
					end,
					get = function(info)
						return ToolTipTabs.db.profile.yoffset
					end,							
				},
				format2 = {
					type = "description",
					name = "\n\nAltering the spacing values will increase the gap between the tabs themselves, this can be useful if you have a ButtonFacade skin that is overlapping or if you just like the look of tabs with more space on the sides.\n",
					order = 4,
					fontSize = "medium",
				},				
				vspacing = {
					type = "range",
					name = "Vertical spacing",
					order = 5,
					min = 0,
					max = 10,
					step = 1,
					set = function(info, v)
						if v > 10 then v = 10 end
						if v < 0 then v = 0 end
						ToolTipTabs.db.profile.vspacing = v
						ToolTipTabs:RedrawAll()
					end,
					get = function(info)
						return ToolTipTabs.db.profile.vspacing
					end,							
				},
				hspacing = {
					type = "range",
					name = "Horizontal spacing",
					order = 6,
					min = 0,
					max = 10,
					step = 1,
					set = function(info, v)
						if v > 10 then v = 10 end
						if v < 0 then v = 0 end
						ToolTipTabs.db.profile.hspacing = v
						ToolTipTabs:RedrawAll()
					end,
					get = function(info)
						return ToolTipTabs.db.profile.hspacing
					end,							
				},					
			},
		},
		tabs = {
			type = "group",
			name = "Tabs",
			order = 5,
			disabled = function()
				return not ToolTipTabs.db.profile.enable
			end,			
			args = {
				columnsize = {
					type = "range",
					name = "Tabs per column",
					set = function(info, v) 
						if v > 5 then v = 5 end
						if v < 1 then v = 1 end
						ToolTipTabs.db.profile.columnsize = v
						ToolTipTabs:CloseExtraTabs()
						ToolTipTabs:RedrawAll() 
					end,
					get = function(info) 
						return ToolTipTabs.db.profile.columnsize  
					end,
					order = 1,
					step = 1,
					min = 1,
					max = 5,
				},
				maxcolumns = {
					type = "range",
					name = "Maximum columns",
					set = function(info, v) 
						if v > 4 then v = 4 end
						if v < 1 then v = 1 end							
						if v < ToolTipTabs.db.profile.maxcolumns then
							ToolTipTabs.db.profile.maxcolumns = v 						
							ToolTipTabs:CloseExtraTabs()
						else
							ToolTipTabs.db.profile.maxcolumns = v  
						end
					end,
					get = function(info) 
						return ToolTipTabs.db.profile.maxcolumns  
					end,					
					order = 2,
					step = 1,
					min = 1,
					max = 4,
				},
				format2 = {
					type = "description",
					name = "\nThe options below allow you to choose the behaviour of the addon when opening a link while at the tab and tooltip limit.\n",
					order = 3,
					fontSize = "medium"
				},
				whattodo1 = {
					type = "toggle",
					name = "Remove the first tab that isn't currently viewed on first tooltip",
					set = function(info, v)
						ToolTipTabs.db.profile.maxxedbehaviour = 1
					end,
					get = function(info)
						if ToolTipTabs.db.profile.maxxedbehaviour == 1 then
							return true
						else
							return false
						end
					end,
					order = 4,
					width = "full",
				},
				whattodo2 = {
					type = "toggle",
					name = "Reset the first tooltip",
					set = function(info, v)
						ToolTipTabs.db.profile.maxxedbehaviour = 2
					end,
					get = function(info)
						if ToolTipTabs.db.profile.maxxedbehaviour == 2 then
							return true
						else
							return false
						end
					end,
					order = 5,
					width = "full",
				},				
			},
		},
		multitooltip = {
			type = "group",
			name = "Multi-tooltip",
			order = 6,
			disabled = function()
				return not ToolTipTabs.db.profile.enable
			end,	
			args = {
				format1 = {
					type = "description",
					name = "If multiple tooltips is enabled in the option below instead of moving the tooltip when you drag a tab, that tab will be added to a newly created tooltip. You can also drag tabs from one tooltip to another.\n",
					order = 1,
					fontSize = "medium",
				},
				multitooltip = {
					type = "toggle",
					name = "Multi-Tooltip",
					order = 2,
					desc = "Use multiple tooltips",
					set = function(info, v) ToolTipTabs.db.profile.multitooltip = v if v == true then ToolTipTabs:EnableAdditionalTT() else ToolTipTabs:DisableAdditionalTT() end end,
					get = function(info) return ToolTipTabs.db.profile.multitooltip end,
				},
				format2 = {
					type = "description",
					name = "\nTotal number of additional tooltips allowed at any one time.\n",
					order = 3,
					fontSize = "medium",
				},
				maxtooltips = {
					type = "range",
					name = "Maximum additional tooltips",
					disabled = function() 
						if not ToolTipTabs.db.profile.multitooltip or not ToolTipTabs.db.profile.enable then
							return true
						else
							return false
						end
					end,
					set = function(info, v) 
						if v > 5 then v = 5 end
						if v < 1 then v = 1 end							
						if v < ToolTipTabs.db.profile.maxtooltips then
							ToolTipTabs.db.profile.maxtooltips = v 
							ToolTipTabs:CloseExtraTT()
						else
							ToolTipTabs.db.profile.maxtooltips = v 
						end
					end,
					get = function(info) 
						return ToolTipTabs.db.profile.maxtooltips  
					end,					
					order = 4,
					min = 1,
					max = 5,
					step = 1,
				},
			},
		},
	},
}
