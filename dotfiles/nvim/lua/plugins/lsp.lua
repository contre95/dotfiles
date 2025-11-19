-- Mappings
vim.keymap.set("n", "<leader>d", ":vs|:Def<cr>")
-- Commands
vim.api.nvim_create_user_command("Info", function()
	return vim.lsp.buf.hover()
end, {})
vim.api.nvim_create_user_command("Rename", function()
	return vim.lsp.buf.rename()
end, {})
vim.api.nvim_create_user_command("Def", function()
	return vim.lsp.buf.definition()
end, {})
vim.api.nvim_create_user_command("Ref", function()
	return vim.lsp.buf.references()
end, {})
vim.api.nvim_create_user_command("DapOpen", function()
	return require("dapui").open()
end, {})
vim.api.nvim_create_user_command("DapClose", function()
	return require("dapui").close()
end, {})
vim.api.nvim_create_user_command("DList", function()
	return vim.diagnostic.setqflist()
end, {})
vim.api.nvim_create_user_command("Imp", function()
	return vim.lsp.buf.implementation()
end, {})
vim.api.nvim_create_user_command("CodeAction", function()
	return vim.lsp.buf.code_action()
end, {})
vim.api.nvim_create_user_command("Diagnose", function()
	return vim.diagnostic.open_float()
end, {})
vim.api.nvim_create_user_command("RemoveBlankLines", function()
	return vim.cmd(":g/^\\s*$/d")
end, {})
vim.api.nvim_create_user_command("Fmt", function()
	return vim.lsp.buf.format({ async = true })
end, {})
vim.api.nvim_create_user_command("SignatureHelp", function()
	return vim.lsp.buf.signature_help()
end, {})
vim.api.nvim_create_user_command("LspLog", function()
	return vim.cmd("sp" .. vim.lsp.get_log_path())
end, {})

-- Set rounded borders for LSP handlers
local handlers = {
	["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
	["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
}

vim.diagnostic.config({
	-- virtual_lines = true,
	virtual_text = true,
	-- float = {
	-- 	border = "rounded",
	-- },
})

-- Define capabilities with cmp_nvim_lsp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Plugin configuration
return {
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local lspconfig = require("lspconfig")

			-- TSServer setup
			local function organize_imports()
				local params = {
					command = "_typescript.organizeImports",
					arguments = { vim.api.nvim_buf_get_name(0) },
				}
				vim.lsp.buf.execute_command(params)
			end

			vim.lsp.config["ts_ls"] = {
				capabilities = capabilities,
				handlers = handlers,
				init_options = {
					preferences = {
						disableSuggestions = true,
					},
				},
				commands = {
					OrganizeImports = {
						organize_imports,
						description = "Organize imports",
					},
				},
			}

			-- Pyright setup
			vim.lsp.config["pyright"] = {
				capabilities = capabilities,
				handlers = handlers,
				filetypes = { "python" },
			}

			-- Terraform setup
			vim.lsp.config["tflint"] = {
				flags = { debounce_text_changes = 150 },
			}

			vim.lsp.config["terraformls"] = {
				capabilities = capabilities,
				on_attach = function(client)
					client.server_capabilities.document_formatting = true
				end,
				cmd = { "terraform-ls", "serve" },
				filetypes = { "tf", "terraform", "tfvars" },
			}

			-- Rust setup
			vim.lsp.config["rust_analyzer"] = {}

			-- BashLS setup
			vim.lsp.config["bashls"] = {
				capabilities = capabilities,
				handlers = handlers,
				filetypes = { "shell", "bash", "zsh", "sh" },
			}

			-- -- Gopls setup
			vim.lsp.config["gopls"] = {
				cmd = { "gopls" },
				root_markers = { ".git", "go.mod", "go.work" },
				filetypes = { "go", "gomod", "gowork", "gotmpl" },
				settings = {
					gopls = {
						completeUnimported = true,
						usePlaceholders = true,
						analyses = {
							unusedparams = true,
						},
						["ui.inlayhint.hints"] = {
							compositeLiteralFields = true,
							constantValues = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
					},
				},
			}

			-- Docker Compose Language Service setup
			vim.lsp.config["docker_compose_language_service"] = {
				capabilities = capabilities,
				handlers = handlers,
				cmd = { "docker-compose-langserver", "--stdio" },
				filetypes = { "yaml.docker-compose" },
				root_dir = require("lspconfig/util").root_pattern(
					"docker-compose.yaml",
					"docker-compose.yml",
					"compose.yaml",
					"compose.yml"
				),
				single_file_support = true,
			}

			-- json
			vim.lsp.config["jsonls"] = {
				commands = {
					Format = {
						function()
							vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line("$"), 0 })
						end,
					},
				},
			}

			-- yaml
			vim.lsp.config["yamlls"] = {
				capabilities = capabilities,
				handlers = handlers,
				settings = {
					yaml = {
						schemas = {
							-- GitLab CI/CD
							["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = {
								".gitlab-ci.yml",
								"*.gitlab-ci.yml",
								".gitlab-ci.yaml",
								"*.gitlab-ci.yaml",
							},
							-- Docker Compose
							["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
								"docker-compose.yml",
								"docker-compose.yaml",
								"docker-compose.*.yml",
								"docker-compose.*.yaml",
								"compose.yml",
								"compose.yaml",
							},
							-- Kubernetes
							["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.28.0/all.json"] = {
								"k8s/**/*.yml",
								"k8s/**/*.yaml",
								"kubernetes/**/*.yml",
								"kubernetes/**/*.yaml",
								"kube/**/*.yml",
								"kube/**/*.yaml",
								"**/k8s/**/*.yml",
								"**/k8s/**/*.yaml",
							},
							-- Helm Charts
							["https://json.schemastore.org/helmfile.json"] = {
								"helmfile.yml",
								"helmfile.yaml",
								"**/helmfile.yml",
								"**/helmfile.yaml",
							},
							-- Prometheus
							["https://json.schemastore.org/prometheus.json"] = {
								"prometheus.yml",
								"prometheus.yaml",
								"**/prometheus/*.yml",
								"**/prometheus/*.yaml",
							},
							-- Grafana Dashboard
							["https://json.schemastore.org/grafana-dashboard.json"] = {
								"**/grafana/**/*.json",
								"**/dashboards/*.json",
							},
							-- Swagger/OpenAPI
							["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.0/schema.json"] = {
								"openapi.yml",
								"openapi.yaml",
								"swagger.yml",
								"swagger.yaml",
								"**/openapi/*.yml",
								"**/openapi/*.yaml",
								"**/swagger/*.yml",
								"**/swagger/*.yaml",
							},
						},
					},
				},
			}

			-- SQL Language Server setup
			vim.lsp.config["sqls"] = {
				capabilities = capabilities,
				handlers = handlers,
				filetypes = { "sql", "pgsql", "mysql" },
				-- root_dir = function(_)
				--   return vim.loop.cwd()
				-- end,
			}

			-- HTML setup
			vim.lsp.config["html"] = {
				capabilities = capabilities,
				handlers = handlers,
			}

			-- HTMX setup
			vim.lsp.config["htmx"] = {
				capabilities = capabilities,
				handlers = handlers,
			}

			-- CSS Language Server setup
			vim.lsp.config["cssls"] = {
				capabilities = capabilities,
				handlers = handlers,
			}

			-- CCLS setup
			vim.lsp.config["ccls"] = {
				capabilities = capabilities,
				handlers = handlers,
				init_options = {
					compilationDatabaseDirectory = "build",
					index = {
						threads = 0,
					},
					clang = {
						excludeArgs = { "-frounding-math" },
					},
				},
			}

			-- Nix setup
			vim.lsp.config["nil"] = {
				capabilities = capabilities,
				handlers = handlers,
        		filetypes = { "nix" },
				settings = {
					["nil"] = {
						formatting = {
							command = { "nixfmt" },
						},
					},
				},
			}
			-- lspconfig.rnix.setup{}

			-- lua
			vim.lsp.config["lua_ls"] = {
				capabilities = capabilities,
				handlers = handlers,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
							disable = { "different-requires" },
						},
					},
				},
			}

			-- Enable LSP servers
			vim.lsp.enable("ts_ls")
			vim.lsp.enable("pyright")
			vim.lsp.enable("tflint")
			vim.lsp.enable("terraformls")
			vim.lsp.enable("rust_analyzer")
			vim.lsp.enable("bashls")
			vim.lsp.enable("gopls")
			vim.lsp.enable("docker_compose_language_service")
			vim.lsp.enable("jsonls")
			vim.lsp.enable("yamlls")
			vim.lsp.enable("sqlls")
			vim.lsp.enable("html")
			vim.lsp.enable("htmx")
			vim.lsp.enable("cssls")
			vim.lsp.enable("ccls")
			vim.lsp.enable("nil_ls")
			vim.lsp.enable("lua_ls")
		end,
	},
}
