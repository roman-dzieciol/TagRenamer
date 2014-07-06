// ============================================================================
//  TagRenamer:	 
//  UnrealEd plugin, renames multiple tags in multiple objects.
// 
//  Copyright 2005 Roman Switch` Dzieciol, neai o2.pl
//  http://wiki.beyondunreal.com/wiki/Switch
// ============================================================================
class TagRenamer extends BrushBuilder
	config(TagRenamer);


// ----------------------------------------------------------------------------
// Constants
// ----------------------------------------------------------------------------

const UID_PREFIX	= "_ID";
const UID_LENGTH 	= 5;
const UID_TOTAL 	= 8;


// ----------------------------------------------------------------------------
// Enums
// ----------------------------------------------------------------------------

enum EPluginAction
{
	A_List,
	A_Rename,
	A_AddPostfix,
	A_AddUnique,
	A_MakeNormal
};


// ----------------------------------------------------------------------------
// Structs
// ----------------------------------------------------------------------------

struct SEditorActor
{
	var string Actor;
	var int MaxId;
};

struct STagActor
{
	var name Name;
	var array<string> Vars;
};

struct STagRef
{
	var() Object Obj;
	var() string Prop;
};

struct STag
{
	var() string Val;
	var() array<STagRef> Refs;
};

struct SRename
{
	var() name Old;
	var() name New;
};



// ----------------------------------------------------------------------------
// Internal
// ----------------------------------------------------------------------------

var config array<STagActor> Actors;				// Supported actors array
var array<STag> TagVars;						// Tags found
var array<int> NamesFound;						// Renamed names counts

var array<SEditorActor> EditorActors;			// 
var Actor TempEditorActor;						// 
	

// ----------------------------------------------------------------------------
// Parameters
// ----------------------------------------------------------------------------

var() EPluginAction Action;		// Chosen Action
var() array<SRename> Names;		// List of names to rename
var() bool bNoSingle;			// Ignore tags found in only one object
var() bool bNoDefault;			// Ignore default tags


// ----------------------------------------------------------------------------
// Tags
// ----------------------------------------------------------------------------

final function bool LoadTags( Actor A )
{
	local Actor Sel;
	
	TagVars.remove(0,TagVars.Length);
	
	// Scan selected actors for tag names
	foreach A.AllActors(class'Actor',Sel)
	{
		if( Sel.bSelected )
		{
			if( !FindTags(Sel) )	
				return false;
		}
	}	
	
	if( TagVars.Length == 0 )
		return ShowError( "No custom tags found." );	
		
	return true;
}
	
final function bool FindTags( Actor A )
{
	local int i,j,k;
	local string TagName;
	local string TagValue;
	local STagRef CRef;
	local STagActor CActor;
	
	// for each supported actor class
	for( i=0; i!=Actors.Length; ++i )
	{
		CActor = Actors[i];
		if( string(CActor.Name) == "" || string(CActor.Name) == "None" )
		{
			return ShowError( "Invalid entry in "$class.name$".ini: Actors["$i$"].Name is empty!" );
		}
		
		// if actor a belongs to this class
		if( A.IsA( CActor.Name ) )
		{
			// check name vars for tags
			for( j=0; j!=CActor.Vars.Length; ++j )
			{
				TagName = CActor.Vars[j];
				if( TagName == "" )
				{
					return ShowError( "Invalid entry in "$class.name$".ini: Actors["$i$"].Vars["$i$"] is empty!" );
				}
				
				// get tag value
				TagValue = "";
				TagValue = A.GetPropertyText( TagName );
				if( TagValue != "" && TagValue != "None" && (bNoDefault == False || TagValue != string(A.class.name)) )
				{
					CRef.Obj = A;
					CRef.Prop = TagName;
					
					// add existing
					for( k=0; k!=TagVars.Length; ++k )
					{
						if( TagVars[k].Val == TagValue )
						{
							TagVars[k].Refs[TagVars[k].Refs.Length] = CRef;
							break;
						}
					}
					
					// add new
					if( k == TagVars.Length )
					{
						k = TagVars.Length;
						TagVars.Insert(k,1);
						TagVars[k].Val = TagValue;
						TagVars[k].Refs[TagVars[k].Refs.Length] = CRef;
					}
				}
			}	
		}
	}	
	return true;
}

final function bool FilterTags()
{
	local int i;
	
	for( i=0; i!=TagVars.Length; ++i )
	{	
		if( TagVars[i].Refs.Length < 2 && bNoSingle )
		{
			Log( "IGNORED: ["$ TagVars[i].Val $"], bNoSingle is enabled.", class.name );
			TagVars.remove(i--,1);
		}
	}	
	
	return true;
}

final function bool CheckNames()
{
	local int i;
	local string N;
	
	if( Names.Length == 0 )
		return ShowError( "You forgot to specify names for action A_Rename." );
		
	for( i=0; i!=Names.Length; ++i )
	{	
		// check old name
		N = string(Names[i].Old);
		if( N == "" || N == "None" )
		{
			return ShowError( "Invalid name: Names["$i$"].Old=" @ Names[i].Old );
		}
		
		// check new name
		N = string(Names[i].New);
		if( N == "" || N == "None" )
		{
			return ShowError( "Invalid name: Names["$i$"].New=" @ Names[i].New );
		}
		
		// check both
		if( string(Names[i].New) == string(Names[i].Old) )
		{
			return ShowError( "Names are equal: Names["$i$"].New=" @ Names[i].New @"Names["$i$"].Old=" @ Names[i].Old );
		}		
	}		
	
	NamesFound.remove(0,NamesFound.Length);
	NamesFound.insert(0,Names.Length);
	
	return true;
}


// ----------------------------------------------------------------------------
// List
// ----------------------------------------------------------------------------

final function bool ListTags()
{
	local int i,j,counter;
	local STag CTag;
	local STagRef CRef;
	
	for( i=0; i!=TagVars.Length; ++i )
	{	
		CTag = TagVars[i];
		Log( "" , class.name );
		for( j=0; j!=CTag.Refs.Length; ++j )
		{	
			CRef = CTag.Refs[j];
			Log( "["$CTag.Val$"]"@ CRef.Prop @ CRef.Obj.name, class.name );
			++counter;
		}
	}	
	Log( "" , class.name );
	
	return ShowSuccess( counter @"Tags listed." );	
}


// ----------------------------------------------------------------------------
// Rename
// ----------------------------------------------------------------------------

final function bool RenameTags()
{
	local int i,j,k,counter;
	local STag CTag;
	local STagRef CRef;
	local SRename CName;	

	for( i=0; i!=TagVars.Length; ++i )
	{	
		CTag = TagVars[i];
		for( k=0; k!=Names.Length; ++k )
		{	
			CName = Names[k];
			if( CTag.Val == string(CName.Old) )
			{
				for( j=0; j!=CTag.Refs.Length; ++j )
				{	
					CRef = CTag.Refs[j];
					CRef.Obj.SetPropertyText( CRef.Prop, string(CName.New) );
					NamesFound[k]++;
					Log( "RENAMED:" @ CName.Old @"TO:"@ CName.New @"IN:"@ CRef.Obj.name @ CRef.Prop, class.name );
					++counter;
				}	
			}			
		}
	}		
	
	for( i=0; i!=NamesFound.Length; ++i )
	{
		if( NamesFound[i] == 0 )
		{
			Log( "Tag ["$ Names[i].Old $"] not found in selected actors.", class.name );
		}
	}	

	
	return ShowSuccess( counter @"Tags renamed." );	
}


// ----------------------------------------------------------------------------
// AddPostFix
// ----------------------------------------------------------------------------

final function bool AddPostFix()
{			
	local string UID,NID;
	local int i,j,counter;
	local STag CTag;
	local STagRef CRef;
	
	// Generate UID
	UID = GenerateUID();
	if( !HasUID(UID) )
		return ShowError( "UID failure:" @ UID );

	for( i=0; i!=TagVars.Length; ++i )
	{	
		CTag = TagVars[i];
		for( j=0; j!=CTag.Refs.Length; ++j )
		{	
			NID = AddUID(CTag.Val,UID);
			CRef = CTag.Refs[j];
			CRef.Obj.SetPropertyText( CRef.Prop, NID );
			Log( "POSTFIX:" @ NID @"OLD:"@ CTag.Val @"IN:"@ CRef.Obj.name @ CRef.Prop, class.name );
			++counter;
		}	
	}		
		
	return ShowSuccess( counter @"Tags postfixed." );	
}


// ----------------------------------------------------------------------------
// AddUnique
// ----------------------------------------------------------------------------

final function bool AddUnique()
{			
	local string UID,NID;
	local int i,j,counter;
	local STag CTag;
	local STagRef CRef;

	for( i=0; i!=TagVars.Length; ++i )
	{	
		CTag = TagVars[i];
		for( j=0; j!=CTag.Refs.Length; ++j )
		{	
			// Generate UID
			UID = GenerateUID();
			if( !HasUID(UID) )
				return ShowError( "UID failure:" @ UID );
				
			NID = AddUID(CTag.Val,UID);
			CRef = CTag.Refs[j];
			CRef.Obj.SetPropertyText( CRef.Prop, NID );
			Log( "UNIQUE:" @ NID @"OLD:"@ CTag.Val @"IN:"@ CRef.Obj.name @ CRef.Prop, class.name );
			++counter;
		}	
	}		
		
	return ShowSuccess( counter @"Tags made unique." );	
}


// ----------------------------------------------------------------------------
// MakeNormal
// ----------------------------------------------------------------------------

final function bool MakeNormal()
{
	local string NID;
	local int i,j,counter;
	local STag CTag;
	local STagRef CRef;

	for( i=0; i!=TagVars.Length; ++i )
	{	
		CTag = TagVars[i];
		for( j=0; j!=CTag.Refs.Length; ++j )
		{	
			NID = RemoveUID(CTag.Val);
			if( NID != CTag.Val )
			{
				CRef = CTag.Refs[j];
				CRef.Obj.SetPropertyText( CRef.Prop, NID );
				Log( "NORMAL:" @ NID @"OLD:"@ CTag.Val @"IN:"@ CRef.Obj.name @ CRef.Prop, class.name );
				++counter;
			}
		}	
	}	
	
	if( counter == 0 )
		Log( "No tags with unique ID found.", class.name );
		
	return ShowSuccess( counter @"Tags made normal." );	
}


// ----------------------------------------------------------------------------
// UID
// ----------------------------------------------------------------------------
final function string GenerateUID()
{
	local string id;
	local int i;
	
	id = UID_PREFIX $ int(RandRange(1,9));
	while( ++i != UID_LENGTH  )
	{
		id = id $ int(RandRange(0,9));
	}
	
	return id;
}

final function bool HasUID( string s )
{
	local int length;
	local string id,num;
	
	length = len(s);
	if( length >= UID_Length )
	{
		id = Mid( s, length-UID_TOTAL, UID_TOTAL-UID_LENGTH );
		num = Mid( s, length-UID_LENGTH, UID_LENGTH );
		if( id == UID_PREFIX && string(int(num)) == (num) )
			return true;
	}
	return false;
}

final function string RemoveUID( string s )
{
	if( HasUID(s) )
		return Left(s,len(s)-UID_TOTAL);
	return s;
}

final function string AddUID( string s, string uid )
{
	return RemoveUID(s) $ uid;
}


// ----------------------------------------------------------------------------
// Main
// ----------------------------------------------------------------------------
event bool Build()
{
	local Actor A;
	
	// Show mode
	Log( "-------------------------------------------------------------------", class.name );
	Log( "ACTION:" @ GetEnum(enum'EPluginAction',Action), class.name );
	Log( "-------------------------------------------------------------------", class.name );
	
	// Find actor reference
	if( !FindAnyActor(A) )
		return false;	
	
	// Scan selected actors for tag names
	if( !LoadTags(A) )
		return false;	
	
	// Filter out tags
	if( !FilterTags() )
		return false;	
	
	// Modes
	switch( Action )
	{
		case A_List:
			if( !ListTags() )	return false;
			break;
		
		case A_Rename:
			if( !CheckNames() )	return false;
			if( !RenameTags() )	return false;
			break;
		
		case A_AddPostfix:
			if( !AddPostfix() )	return false;
			break;
		
		case A_AddUnique:
			if( !AddUnique() )	return false;
			break;
		
		case A_MakeNormal:
			if( !MakeNormal() )	return false;
			break;
	}
	
	return false;
}


// ----------------------------------------------------------------------------
// Internal
// ----------------------------------------------------------------------------

function bool ShowSuccess( coerce string S )
{
	Log( "" $ S, class.name );
	BadParameters( "" $ S );
	return true;
}

function bool ShowError( coerce string S )
{
	Log(  "Error: " $ S, class.name );
	BadParameters( "Error: " $ S );
	return false;
}

function bool FindAnyActor( out Actor A )
{
	local SEditorActor E;
	local int i,j;
	
	for( i=0; i!=EditorActors.Length; ++i )
	{
		E = EditorActors[i];
		for( j=0; j!=E.MaxId; ++j )
		{
			SetPropertyText("TempEditorActor",E.Actor$j);
			if( TempEditorActor != None )
			{
				A = TempEditorActor;
				TempEditorActor = None;
				Log( "Actor Ref:" @ A, class.name );
				return true;
			}
		}
	}	
	return ShowError( "Could not find any actors in the level." );
}


// ----------------------------------------------------------------------------
// DefaultProperties
// ----------------------------------------------------------------------------
DefaultProperties
{
	ToolTip="TagRenamer"
	BitmapFilename="TagRenamer"
	
	Action=A_List
	bNoSingle=False
	bNoDefault=True
	
	EditorActors(0)=(Actor="MyLevel.LevelInfo",MaxId=8)
	EditorActors(1)=(Actor="MyLevel.Camera",MaxId=64)
	EditorActors(2)=(Actor="MyLevel.Brush",MaxId=128)
}