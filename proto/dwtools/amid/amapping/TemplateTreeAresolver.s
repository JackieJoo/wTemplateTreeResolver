( function _TemplateTreeAresolver_s_( ) {

'use strict';

/**
  @module Tools/mid/TemplateTreeResolver - Class to resolve tree-like with links data structures or paths in the structure. Use the module to resolve template or path to value.
*/

/**
 * @file TemplateTreeResolver.s.
 */

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

  let _ = _global_.wTools;

  _.include( 'wCopyable' );

}

let _ = _global_.wTools;
let Parent = null;
let Self = function wTemplateTreeResolver( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'TemplateTreeResolver';

// --
// inter
// --

function init( o )
{
  let self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.instanceInit( self );

  if( self.constructor === Self )
  Object.preventExtensions( self );

  if( o )
  self.copy( o );

}

// --
// resolve
// --

function resolve( src )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let result = self._resolveEnter( src,'' );

  if( result instanceof self.ErrorQuerying )
  {
    debugger;
    let result = self._resolveEnter( src,'' );
    throw _.err( result );
  }

  return result;
}

//

function resolveTry( src )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let result = self._resolve( src );

  if( result instanceof self.ErrorQuerying )
  return;

  return result;
}

//

function _resolve( src )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let result = self._resolveEnter( src,'' );

  return result;
}

//

function _resolveEnter( src,query )
{
  let self = this;
  let l = self.current.length;
  let node,path;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  if( query === '' )
  {
    _.assert( l === 0 );
    node = self.tree;
    path = self.upSymbol;
  }
  else
  {
    node = src;
    path = self.current[ self.current.length-1 ].path;
  }

  let entered = self._enter( node,[ query ],path,0 );
  if( entered instanceof self.ErrorQuerying )
  {
    debugger;
    return entered;
  }

  let result = self._resolveEntered( src );

  self._leave( node );
  _.assert( self.current.length === l );

  return result;
}

//

function _resolveEntered( src )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( !self.shouldInvestigate( src ) )
  return src;

  if( _.strIs( src ) )
  return self._resolveString( src );

  if( _.regexpIs( src ) )
  return self._resolveRegexp( src );

  if( _.mapIs( src ) )
  return self._resolveMap( src );

  if( _.longIs( src ) )
  return self._resolveArray( src );

  throw _.err( 'repalce : unexpected type of src',_.strTypeOf( src ) );
}

//


function _join()
{
  let result = '';
  for( var i = 0; i < arguments.length; i++ )
  {
    _.assert( _.strIs( arguments[ i ] ), 'Can\'t join elements:', '\n', arguments, '\n', 'Expects String, but got:', arguments[ i ] );
    result += arguments[ i ];
  }
  return result;
}

let join = _.routineVectorize_functor
({
  routine : _join,
  vectorizingArray : 1,
  vectorizingMap : 1,
  vectorizingKeys : 0,
  select : Infinity
})

//

function _resolveString( src )
{
  let self = this;
  let r;
  let rarray = [];

  if( src === '' )
  return src;

  let optionsForExtract =
  {
    src : src,
    prefix : self.prefixSymbol,
    postfix : self.postfixSymbol,
    onInlined : function( src ){ return [ src ]; },
  }

  let strips = _.strExtractInlinedStereo( optionsForExtract );

  /* */

  for( let s = 0 ; s < strips.length ; s++ )
  {
    let element;
    let strip = strips[ s ];

    if( _.strIs( strip ) )
    {
      element = strip;
    }
    else
    {
      element = self._queryEntered( strip[ 0 ] );
    }

    if( _.arrayIs( strip ) )
    strip = strip[ 0 ];

    if( element instanceof self.ErrorQuerying )
    {
      debugger;
      element = _.err( 'Cant resolve', _.strQuote( src.substring( 0,80 ) ), '\n', _.strQuote( strip ), 'is not defined', '\n', element );
      return element;
    }

    if( strips.length > 1 )
    {
      element = self.strFrom( element );
      if( !_.strIs( element ) && !_.arrayIs( element ) && !_.mapIs( element ) )
      {
        debugger;
        element = _.err
        (
         'Cant resolve', _.strQuote( src.substring( 0,80 ) ), '\n', _.strQuote( strip ), 'is', _.strTypeOf( element ), '\n',
         'Allowed types are: String, Array, Map'
        );
        return element;
      }
    }

    rarray.push( element );

  }

  /* */

  if( rarray.length < 2 )
  return rarray[ 0 ];

  let result;

  try
  {
    result = join.apply( self, rarray );
  }
  catch( err )
  {
    throw _.err( 'Can\'t mix elements of template:',_.strQuote( src.substring( 0,80 ) ),'\n','Elements:\n',rarray,'\n', err.message );
  }

  /* */

  // let result = '';
  // for( let r = 0 ; r < rarray.length ; r++ )
  // {
  //   let element = rarray[ r ];
  //   if( _.arrayIs( element ) )
  //   {
  //     _.sure( _.strIs( result ),'Cant mix', _.strTypeOf( [] ),'with',_.strTypeOf( result ) );
  //     result = _.dup( '',element.length );
  //     _.assert( result.length === element.length );
  //   }
  //   else if( _.mapIs( element ) )
  //   {
  //     _.sure( _.strIs( result ),'Cant mix', _.strTypeOf( Object.create( null ) ),'with',_.strTypeOf( result ) );
  //     result = _.mapExtend( null,element );
  //     for( let i in result )
  //     result[ i ] = '';
  //   }
  //   else
  //   {
  //     // _.assert( _.strIs( element ) );
  //   }
  // }

  /* */

  // for( let r = 0 ; r < rarray.length ; r++ )
  // {
  //   let element = rarray[ r ];

  //   if( _.arrayIs( result ) )
  //   {
  //     for( let i = 0 ; i < result.length ; i++ )
  //     if( _.arrayIs( element ) )
  //     result[ i ] = join( result[ i ] , element[ i ] );
  //     else
  //     result[ i ] = join( result[ i ] , element );
  //   }
  //   else if( _.mapIs( result ) )
  //   {
  //     debugger;
  //     for( let i in result )
  //     if( _.mapIs( element ) )
  //     result[ i ] = join( result[ i ] , element[ i ] );
  //     else
  //     result[ i ] = join( result[ i ] , element );
  //   }
  //   else
  //   {
  //     result = join( result , element );
  //   }

  // }

  return result;

  /* - */

  // function join( result, element )
  // {
  //   result += element;
  //   _.assert( _.strIs( result ) );
  //   _.assert( _.strIs( element ) );
  //   return result;
  // }
}

//

function _resolveRegexp( src )
{
  let self = this;

  _.assert( _.regexpIs( src ) );

  let source = src.source;
  source = self._resolveString( source );

  if( source instanceof self.ErrorQuerying )
  return source;

  if( source === src.source )
  return src;

  src = new RegExp( source,src.flags );

  return src;
}

//

function _resolveMap( src )
{
  let self = this;
  let result = Object.create( null );

  for( let s in src )
  {
    result[ s ] = self._resolveEnter( src[ s ],s );
    if( result[ s ] instanceof self.ErrorQuerying )
    {
      return result[ s ];
    }
  }

  return result;
}

//

function _resolveArray( src )
{
  let self = this;
  let result = new src.constructor( src.length );

  for( let s = 0 ; s < src.length ; s++ )
  {
    result[ s ] = self._resolveEnter( src[ s ],s );
    if( result[ s ] instanceof self.ErrorQuerying )
    {
      return result[ s ];
    }
  }

  return result;
}

// --
// query
// --

function query( query )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let result = self._queryEntering( query );
  if( result instanceof self.ErrorQuerying )
  {
    debugger;
    throw _.err( result,'\nquery :',query );
  }

  return result;
}

//

function queryTry( query )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let result = self._queryEntering( query );
  if( result instanceof self.ErrorQuerying )
  return;

  return result;
}

//

function _querySplit( query )
{
  let self = this;

  _.assert( _.strIs( query ) || _.arrayIs( query ) );
  _.assert( arguments.length === 1, 'Expects single argument' );

  if( _.strIs( query ) )
  {

    /* query = query.split( self.upSymbol ); */

    query = _.strSplit
    ({
      src : query,
      delimeter : [ self.upSymbol,self.downSymbol ],
      preservingDelimeters : 1,
      preservingEmpty : 0,
    });

    if( query[ 0 ] !== self.downSymbol && query[ 0 ] !== self.upSymbol )
    query.unshift( self.upSymbol );

  }

  return query;
}

//

function _queryEntering( query )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !self.current.length );

  query = self._querySplit( query );

  //self._enter( self.tree,query,self.upSymbol,1 );
  self._enter( self.tree,query,'',1 );

  let result = self._queryEntered( query );

  self._leave( self.tree );
  _.assert( self.current.length === 0 );

  return result;
}

//

function _queryEntered( query )
{
  let self = this;

  _.assert( _.strIs( query ) || _.arrayIs( query ) );
  _.assert( arguments.length === 1, 'Expects single argument' );

  if( _.strIs( query ) )
  {
    query = self._querySplit( query );
  }

  let result = self._queryAct( self.tree,query );

  return result;
}

//

function _queryAct( here,query )
{

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( query.length > 0 );
  // _.assert( query[ 0 ] === self.upSymbol || query[ 0 ] === self.downSymbol );

  let result;
  let self = this;
  let path = self.current[ self.current.length-1 ].path;
  let queryOriginal = query;
  let newQuery;

  /* clear from up symbol */

  if( query[ 0 ] === self.upSymbol )
  query.splice( 0,1 );

  /* clear from down symbol or select */

  if( query[ 0 ] === self.downSymbol )
  {
    for( var q = 0 ; q < query.length ; q++ )
    if( query[ q ] !== self.downSymbol )
    break;
    query.splice( 0,q );
    if( self.current.length >= q )
    result = self.current[ self.current.length-q ].node;
    newQuery = query.slice();
  }
  else
  {
    if( !here )
    {
      // debugger;
      return self._errorQuerying({ at : path, query : queryOriginal.join( self.upSymbol ) });
    }
    result = here[ query[ 0 ] ];
    newQuery = query.slice( 1 );
  }

  /* */

  if( result === undefined )
  {
    // debugger;
    return self._errorQuerying({ at : path, query : queryOriginal.join( self.upSymbol ) });
  }

  /* */

  let current = result;
  let entered = self._enter( current,query,path,0 );
  if( entered instanceof self.ErrorQuerying )
  {
    debugger;
    return self._errorQuerying({ reason : 'dead cycle', at : path, query : queryOriginal.join( self.upSymbol ) });
  }

  /* */

  if( newQuery.length )
  {
    if( _.strIs( result ) )
    result = self._resolveEntered( result );
    if( result !== undefined )
    result = self._queryAct( result,newQuery );
  }
  else
  {
    result = self._resolveEntered( result );
  }

  /* */

  self._leave( current );

  if( result === undefined )
  {
    debugger;
    return self._errorQuerying({ at : path, query : query.join( self.upSymbol ) });
  }

  return result;
}

// --
// tracker
// --

function _entryGet( entry )
{
  let self = this;

  let result = _.entityFilter( self.current,entry );

  return result;
}

//

function _enter( node,query,path,throwing )
{
  let self = this;

  _.assert( arguments.length === 4 );
  _.assert( _.arrayIs( query ) );

  let newPath;

  if( path === '' )
  newPath = '/'
  else if( path === '/' )
  newPath = path + query[ 0 ];
  else
  newPath = path + query[ 0 ] + query[ 1 ];

  // let newPath = path !== self.upSymbol ? path + query[ 0 ] + query[ 1 ] : path + query[ 0 ]; debugger;
  // let newPath = path + query[ 0 ] + query[ 1 ]; debugger;

  let d = {};
  d.node = node;
  d.path = newPath;
  d.query = query.join( '' );
  //d.query = query.join( self.upSymbol );

  if( query )
  if( self._entryGet({ query : d.query, node : node }).length )
  {
    let err = self._errorQuerying({ reason : 'dead cycle', at : newPath, query : d.query });;
    if( throwing )
    throw err;
    else
    return err;
  }

  self.current.push( d );

  return d;
}

//

function _leave( node )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let d = self.current.pop();

  _.assert( d.node === node );

  return d;
}

// --
// etc
// --

function ErrorQuerying( o )
{
  _.mapExtend( this,o );
  //self.stack = _.diagnosticStack();
}

ErrorQuerying.prototype = Object.create( Error.prototype );
ErrorQuerying.prototype.constructor = ErrorQuerying;
ErrorQuerying.prototype.name = 'x';

//

function _errorQuerying( o )
{
  // debugger;
  let err = new ErrorQuerying( o );
  err = _.err( err );
  _.assert( err instanceof Error );
  _.assert( err instanceof ErrorQuerying );
  _.assert( !!err.stack );
  return err;
}

//

function shouldInvestigate( src )
{
  let self = this;

  if( _.strIs( src ) )
  return self.investigatingString;

  if( _.mapIs( src ) )
  return self.investigatingMap;

  if( _.regexpIs( src ) )
  return self.investigatingRegexp;

  if( _.longIs( src ) )
  return self.investigatingArrayLike;

  return false;
}

//

function strFrom( src )
{
  let self = this;

  if( _.regexpIs( src ) )
  src = src.source;

  if( !_.strIs( src ) && self.onStrFrom )
  src = self.onStrFrom( src );

  return src;
}

//

function entityResolve( src,tree )
{
  if( tree === undefined )
  tree = src;
  _.assert( arguments.length === 1 || arguments.length === 2 );
  let self = new Self({ tree : tree });
  return self.resolve( src );
}

// --
// shortcuts
// --

function resolveAndAssign( src )
{
  let self = this;

  if( src !== undefined )
  self.tree = src;

  self.tree = self.resolve( self.tree );

  return self.tree;
}

// --
// relations
// --

let Composes =
{

  investigatingString : true,
  investigatingMap : true,
  investigatingRegexp : true,
  investigatingArrayLike : true,

  current : _.define.own([]),

  prefixSymbol : '{{',
  postfixSymbol : '}}',
  downSymbol : '^',
  upSymbol : '/',

  onStrFrom : null,

}

let Associates =
{
  tree : null,
}

let Restricts =
{
}

let Statics =
{
  ErrorQuerying : ErrorQuerying,
  entityResolve : entityResolve,
}

let Globals =
{
  entityResolve : entityResolve,
}

// --
// declare
// --

let Proto =
{

  init : init,

  // resolve

  resolve : resolve,
  resolveTry : resolveTry,
  _resolve : _resolve,
  _resolveEnter : _resolveEnter,
  _resolveEntered : _resolveEntered,
  _resolveString : _resolveString,
  _resolveMap : _resolveMap,
  _resolveArray : _resolveArray,
  _resolveRegexp : _resolveRegexp,

  // query

  query : query,
  queryTry : queryTry,
  _querySplit : _querySplit,
  _queryEntering : _queryEntering,
  _queryEntered : _queryEntered,
  _queryAct : _queryAct,

  // tracker

  _entryGet : _entryGet,
  _enter : _enter,
  _leave : _leave,

  // etc

  _errorQuerying : _errorQuerying,
  shouldInvestigate : shouldInvestigate,
  strFrom : strFrom,
  entityResolve : entityResolve,

  // shortcuts

  resolveAndAssign : resolveAndAssign,

  // relations

  Composes : Composes,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,
  Globals : Globals,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );
_.mapExtend( _global_,Globals );

//

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

_[ Self.shortName ] = _global_[ Self.name ] = Self;
if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();