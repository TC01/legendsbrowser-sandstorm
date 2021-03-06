@0xd6b6ab99c60c93d1;

using Spk = import "/sandstorm/package.capnp";
# This imports:
#   $SANDSTORM_HOME/latest/usr/include/sandstorm/package.capnp
# Check out that file to see the full, documented package definition format.

const pkgdef :Spk.PackageDefinition = (
  # The package definition. Note that the spk tool looks specifically for the
  # "pkgdef" constant.

  id = "8cqz32rgsth404ma1humv0j86s6wx41y99krqn8885k01r96vgg0",
  # Your app ID is actually its public key. The private key was placed in
  # your keyring. All updates must be signed with the same key.

  manifest = (
    appTitle = (defaultText = "Legends Browser"),

    appVersion = 6,  # Increment this for every release.

    appMarketingVersion = (defaultText = "0.1.5"),
    # Human-readable representation of appVersion. Should match the way you
    # identify versions of your app in documentation and marketing.

    actions = [
      ( nounPhrase = (defaultText = "instance"),
        command = .myCommand
      )
    ],

    continueCommand = .myCommand,

    metadata = (
      icons = (
        # Various icons to represent the app in various contexts.
        appGrid = (png = (dpi1x = embed "../icons/df_appgrid.png")),
        #grain = (svg = embed "path/to/grain-24x24.svg"),
        #market = (svg = embed "path/to/market-150x150.svg"),
        marketBig = (png = (dpi1x = embed "../icons/df_market_full.png")),
      ),

      website = "https://github.com/TC01/legendsbrowser-sandstorm",

      codeUrl = "https://github.com/TC01/legendsbrowser-sandstorm",

      license = (openSource = mit),

      categories = [games, media],

      author = (
        contactEmail = "rosser.bjr@gmail.com",

        pgpSignature = embed "pgp-signature",

        upstreamAuthor = "Robert Janetzko",
      ),

      pgpKeyring = embed "pgp-keyring",

      description = (defaultText = embed "description.md"),

      shortDescription = (defaultText = "DF legends viewer"),

      screenshots = [
        (width = 1445, height = 987, png = embed "../screenshots/legendsbrowser-sandstorm-main.png"),
        (width = 1438, height = 715, png = embed "../screenshots/legendsbrowser-sandstorm-mountainhalls.png"),
      ],

      changeLog = (defaultText = embed "../CHANGELOG.md"),
    ),
  ),

  sourceMap = (
    searchPath = [
      ( sourcePath = "." ),  # Search this directory first.
      ( sourcePath = "/",    # Then search the system root directory.
        hidePaths = [ "home", "proc", "sys",
                      "etc/passwd", "etc/hosts", "etc/host.conf",
                      "etc/nsswitch.conf", "etc/resolv.conf" ]
      )
    ]
  ),

  fileList = "sandstorm-files.list",

  alwaysInclude = [],

  bridgeConfig = (
    # Used for integrating permissions and roles into the Sandstorm shell
    # and for sandstorm-http-bridge to pass to your app.
    # Uncomment this block and adjust the permissions and roles to make
    # sense for your app.
    # For more information, see high-level documentation at
    # https://docs.sandstorm.io/en/latest/developing/auth/
    # and advanced details in the "BridgeConfig" section of
    # https://github.com/sandstorm-io/sandstorm/blob/master/src/sandstorm/package.capnp
    viewInfo = (
      # For details on the viewInfo field, consult "ViewInfo" in
      # https://github.com/sandstorm-io/sandstorm/blob/master/src/sandstorm/grain.capnp
  
      permissions = [
      # Permissions which a user may or may not possess.  A user's current
      # permissions are passed to the app as a comma-separated list of `name`
      # fields in the X-Sandstorm-Permissions header with each request.
      #
      # IMPORTANT: only ever append to this list!  Reordering or removing fields
      # will change behavior and permissions for existing grains!  To deprecate a
      # permission, or for more information, see "PermissionDef" in
      # https://github.com/sandstorm-io/sandstorm/blob/master/src/sandstorm/grain.capnp
        (
          name = "editor",
          # Name of the permission, used as an identifier for the permission in cases where string
          # names are preferred.  Used in sandstorm-http-bridge's X-Sandstorm-Permissions HTTP header.
  
          title = (defaultText = "uploader"),
          # Display name of the permission, e.g. to display in a checklist of permissions
          # that may be assigned when sharing.
  
          description = (defaultText = "grants ability to upload legends data"),
          # Prose describing what this role means, suitable for a tool tip or similar help text.
        ),
      ],
      roles = [
        (
          title = (defaultText = "uploader"),
  
          permissions  = [true],
  
          verbPhrase = (defaultText = "can upload"),
  
          description = (defaultText = "uploaders may upload new legends files."),
        ),
        (
          title = (defaultText = "viewer"),
          permissions  = [false],
          verbPhrase = (defaultText = "can view"),
          description = (defaultText = "viewers may read the world's legends."),
        ),
      ],
    ),
    #apiPath = "/api",
    # Apps can export an API to the world.  The API is to be used primarily by Javascript
    # code and native apps, so it can't serve out regular HTML to browsers.  If a request
    # comes in to your app's API, sandstorm-http-bridge will prefix the request's path with
    # this string, if specified.
  ),
);

const myCommand :Spk.Manifest.Command = (
  # Here we define the command used to start up your server.
  argv = ["/sandstorm-http-bridge", "8000", "--", "/opt/app/.sandstorm/launcher.sh"],
  environ = [
    # Note that this defines the *entire* environment seen by your app.
    (key = "PATH", value = "/usr/local/bin:/usr/bin:/bin"),
	(key = "HOME", value = "/var"),
    (key = "SANDSTORM", value = "1"),
    # Export SANDSTORM=1 into the environment, so that apps running within Sandstorm
    # can detect if $SANDSTORM="1" at runtime, switching UI and/or backend to use
    # the app's Sandstorm-specific integration code.
  ]
);
